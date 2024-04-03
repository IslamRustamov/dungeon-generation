with (obj_hero) {
	var _path = path_add();
	if mp_grid_path(global.mp_map, _path, x, y, mouse_x, mouse_y, 0) {
	    path_start(_path, 10, 0, 0);
	}
}
