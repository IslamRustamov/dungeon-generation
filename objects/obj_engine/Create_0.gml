randomize();

cell_size = 50;

width = room_width div cell_size;
height = room_width div cell_size;

// how many caves we would prefer
var _caves_to_cover = 50;

// final map with random caves
new_map = ds_grid_create(width, height);

var _filled_directions = [];

// trying to find the first room in the original ds
var _first_i = irandom_range(4, width - 4);
var _first_j = irandom_range(4, height - 4);

ds_grid_set(new_map, _first_i, _first_j, 1)
array_push(_filled_directions, {i: _first_i, j: _first_j})
_caves_to_cover--;

var _generation_state = "BUILDING_RANDOM_PATH";


var _retries = 100;

// trying to build a path
while (_generation_state == "BUILDING_RANDOM_PATH") {
	// choosing direction to go to
	var _direction = choose("up", "left", "right", "down");
	var _direction_i = _first_i;
	var _direction_j = _first_j;
	
	if _direction == "up" {
		_direction_i = _first_i + 2
	} else if _direction == "down" {
		_direction_i = _first_i - 2
	} else if _direction == "left" {
		_direction_j = _first_j - 2
	} else if _direction == "right" {
		_direction_j = _first_j + 2
	}
	
	// checking if room was already visited
	var _was_visited_already = false
	
	for (var _l = 0; _l < array_length(_filled_directions); _l++) {
		if (_filled_directions[_l].i == _direction_i and _filled_directions[_l].j == _direction_j) {
			_was_visited_already = true
		}
	}
	
	// checking if new location is in bounds and was not visited
	if (
		_direction_i >= width - 2 or
		_direction_i <= 1 or 
		_direction_j >= height - 2 or
		_direction_j <= 1 or 
		_was_visited_already
		) {
		if (array_length(_filled_directions) > 0) {
			var _elem = array_get(_filled_directions, irandom_range(0, array_length(_filled_directions) - 1))
		
			_first_i = _elem.i;
			_first_j = _elem.j		
		}

		_retries--
		
		if (_retries < 0) {
			_generation_state = "DONE";
		}
		continue;
	}
	
	//if we found a new room - putting it in new ds and creating path
	ds_grid_set(new_map, _direction_i, _direction_j, 1)
		
	if _direction == "up" {
		ds_grid_set(new_map, _direction_i - 1, _direction_j, 2)
	} else if _direction == "down" {
		ds_grid_set(new_map, _direction_i + 1, _direction_j, 2)
	} else if _direction == "left" {
		ds_grid_set(new_map, _direction_i, _direction_j + 1, 3)
	} else if _direction == "right" {
		ds_grid_set(new_map, _direction_i, _direction_j - 1, 3)
	}
		
	_first_i = _direction_i;
	_first_j = _direction_j;
	array_push(_filled_directions, {i: _direction_i, j: _direction_j})
		
	_caves_to_cover--;

	if (_caves_to_cover < 1) {
		_generation_state = "DONE";
	}
}

// creating instances
for (var _i = 0; _i < width; _i++){
	for (var _j = 0; _j < height; _j++) {
		var _element = ds_grid_get(new_map, _i, _j);
		if (_element == 0) {
			instance_create_layer(_i * cell_size, _j * cell_size, "Instances", obj_wall)
		} else if (_element == 1) {
			instance_create_layer(_i * cell_size, _j * cell_size, "Instances", obj_room)
			if (!instance_exists(obj_hero)) {
				instance_create_layer(_i * cell_size + obj_room.sprite_width / 2, _j * cell_size + obj_room.sprite_height / 2, "Instances", obj_hero, {depth: -10})
			}
		} else if (_element == 2) {
			var _path = instance_create_layer(_i * cell_size, _j * cell_size, "Instances", obj_path)
			_path.y += obj_room.sprite_height / 2;
		} else if (_element == 3) {
			var _path = instance_create_layer(_i * cell_size, _j * cell_size, "Instances", obj_path)
			_path.image_angle = 270
			_path.x += obj_room.sprite_height / 2;
		}
	}
}

global.mp_map = mp_grid_create(0, 0, width, height, cell_size, cell_size);

function occupied(_value, x, y)
{
    switch(_value)
    {
        case 0:
            return true;
        default:
            return false;
    }
}

ds_grid_to_mp_grid(new_map, global.mp_map, occupied);


