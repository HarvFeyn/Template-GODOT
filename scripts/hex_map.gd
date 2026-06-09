# hex_map.gd
class_name HexMap
extends Node3D

const HEX_TILE: PackedScene = preload("res://scenes/game/hex_tile.tscn")
const HEX_SIZE: float = 1.0

# Carte définie manuellement — facile à modifier pour tester
const MAP_DATA: Array = [
	[0, 0, 1, 0, 0],
	[0, 2, 2, 3, 0],
	[1, 0, 0, 0, 1],
	[0, 3, 2, 2, 0],
	[0, 0, 1, 0, 0],
]

var _tiles: Dictionary = {}          # Vector3i → HexTile
var _selected_tile: HexTile = null
var _hovered_tile: HexTile = null

@onready var _camera: Camera3D = $Camera3D

func _ready() -> void:
	_generate_map()

func _physics_process(_delta: float) -> void:
	_update_hover()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_click()

# --- Génération ---

func _generate_map() -> void:
	for r: int in MAP_DATA.size():
		for q : int in MAP_DATA[r].size():
			var type: Enums.TileType = MAP_DATA[r][q] as Enums.TileType
			var coords: Vector3i = Vector3i(q, -q - r, r)  # conversion en cubique
			var tile: HexTile = HEX_TILE.instantiate()
			add_child(tile)
			tile.position = _cube_to_world(coords)
			tile.setup(type, coords)
			_tiles[coords] = tile

func _cube_to_world(coords: Vector3i) -> Vector3:
	var q: float = coords.x
	var r: float = coords.z
	var x: float = HEX_SIZE * 1.5 * q
	var z: float = HEX_SIZE * sqrt(3.0) * (r + q / 2.0)
	return Vector3(x, 0.0, z)

# --- Hover & Sélection ---

func _update_hover() -> void:
	print("handle hover")
	var tile: HexTile = _get_tile_under_mouse()
	print("tile : " + str(tile))
	if tile == _hovered_tile:
		return
	if _hovered_tile and _hovered_tile != _selected_tile:
		_hovered_tile.unhover()
	_hovered_tile = tile
	if _hovered_tile and _hovered_tile != _selected_tile:
		_hovered_tile.hover()

func _handle_click() -> void:
	if _hovered_tile == null:
		return
	if _selected_tile:
		_selected_tile.deselect()
	if _selected_tile == _hovered_tile:
		_selected_tile = null
		return
	_selected_tile = _hovered_tile
	_selected_tile.select()
	EventBus.tile_selected.emit(_selected_tile)

func _get_tile_under_mouse() -> HexTile:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = _camera.project_ray_origin(mouse_pos)
	var ray_end: Vector3 = ray_origin + _camera.project_ray_normal(mouse_pos) * 1000.0
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result: Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var collider: Object = result["collider"]
	if collider is HexTile:
		return collider as HexTile
	return null
