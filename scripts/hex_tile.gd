# hex_tile.gd
class_name HexTile
extends StaticBody3D

static var TILE_COLORS: Dictionary = {
	Enums.TileType.GRASS:    Color(0.44, 0.70, 0.25),
	Enums.TileType.WATER:    Color(0.20, 0.52, 0.82),
	Enums.TileType.MOUNTAIN: Color(0.55, 0.50, 0.45),
	Enums.TileType.FOREST:   Color(0.18, 0.42, 0.18),
}

static var TILE_HEIGHTS: Dictionary = {
	Enums.TileType.GRASS:    0.6,
	Enums.TileType.WATER:    0.3,
	Enums.TileType.MOUNTAIN: 1.2,
	Enums.TileType.FOREST:   0.8,
}

const HEX_SIZE: float = 1.0
const SELECTED_OFFSET_Y: float = 0.6
const SELECTED_SCALE: float = 1.0
const HOVER_EMISSION_ENERGY: float = 0.3

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D

var tile_type: Enums.TileType = Enums.TileType.GRASS
var hex_coords: Vector3i = Vector3i.ZERO  # coordonnées cubiques (q, r, s)

var _base_y: float = 0.0
var _material: StandardMaterial3D

func setup(type: Enums.TileType, coords: Vector3i) -> void:
	tile_type = type
	hex_coords = coords
	_build_mesh()

func _build_mesh() -> void:
	var height: float = TILE_HEIGHTS[tile_type]
	_base_y = height / 2.0  # ← le centre du mesh est à mi-hauteur
	position.y = _base_y    # ← on positionne la tuile pour que sa base soit à y=0

	var mesh: ArrayMesh = _create_hex_prism(HEX_SIZE, height)
	_mesh_instance.mesh = mesh

	_material = StandardMaterial3D.new()
	_material.albedo_color = TILE_COLORS[tile_type]
	_mesh_instance.material_override = _material

	var shape: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
	shape.points = _get_hex_prism_points(HEX_SIZE, height)
	_collision_shape.shape = shape

func hover() -> void:
	print("hover")
	_material.emission_enabled = true
	_material.emission = Color.WHITE
	_material.emission_energy_multiplier = HOVER_EMISSION_ENERGY

func unhover() -> void:
	print("unhover")
	_material.emission_enabled = false

func select() -> void:
	unhover()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", _base_y + SELECTED_OFFSET_Y, 0.2)
	tween.parallel().tween_property(
		_mesh_instance, "scale",
		Vector3(SELECTED_SCALE, 1.0, SELECTED_SCALE), 0.2
	)

func deselect() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", _base_y, 0.15)
	tween.parallel().tween_property(_mesh_instance, "scale", Vector3.ONE, 0.15)


func _create_hex_prism(size: float, height: float) -> ArrayMesh:
	var vertices: PackedVector3Array = []
	var normals: PackedVector3Array = []

	var top_verts: Array[Vector3] = []
	var bot_verts: Array[Vector3] = []

	for i: int in 6:
		var angle: float = deg_to_rad(60.0 * i)
		var x: float = size * cos(angle)
		var z: float = size * sin(angle)
		top_verts.append(Vector3(x, height, z))
		bot_verts.append(Vector3(x, 0.0, z))

	# Face du dessus
	for i: int in 6:
		vertices.append(Vector3(0, height, 0))
		vertices.append(top_verts[i])
		vertices.append(top_verts[(i + 1) % 6])
		normals.append_array([Vector3.UP, Vector3.UP, Vector3.UP])

	# Face du dessous
	for i: int in 6:
		vertices.append(Vector3(0, 0.0, 0))
		vertices.append(bot_verts[(i + 1) % 6])
		vertices.append(bot_verts[i])
		normals.append_array([Vector3.DOWN, Vector3.DOWN, Vector3.DOWN])

	# Faces latérales avec normales corrigées
	for i: int in 6:
		var next: int = (i + 1) % 6
		var t0: Vector3 = top_verts[i]
		var t1: Vector3 = top_verts[next]
		var b0: Vector3 = bot_verts[i]
		var b1: Vector3 = bot_verts[next]

		# Normale calculée vers l'extérieur
		var mid: Vector3 = ((t0 + t1 + b0 + b1) / 4.0)
		var normal: Vector3 = Vector3(mid.x, 0.0, mid.z).normalized()

		vertices.append_array([t0, t1, b0])
		normals.append_array([normal, normal, normal])
		vertices.append_array([t1, b1, b0])
		normals.append_array([normal, normal, normal])

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals

	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func _get_hex_prism_points(size: float, height: float) -> PackedVector3Array:
	var half: float = height / 2.0
	var points: PackedVector3Array = []
	for i: int in 6:
		var angle: float = deg_to_rad(60.0 * i)
		var x: float = size * cos(angle)
		var z: float = size * sin(angle)
		points.append(Vector3(x, -half, z))
		points.append(Vector3(x,  half, z))
	points.append(Vector3(0, -half, 0))
	points.append(Vector3(0,  half, 0))
	return points
