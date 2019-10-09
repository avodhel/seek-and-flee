extends Area2D

export (int, "SEEK", "FLEE") var mode = 0

const MAX_SPEED = 45
const MAX_FORCE = 1
const DETECT_RADIUS = 200
const FOV = 80

onready var target = self.position

var angle = 0
var direction = Vector2()
var velocity = Vector2()

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	_move(delta)
	_fov_movement(delta)

func _move(delta):
	velocity = steer(target)
	move_local_x(velocity.x * delta)
	move_local_y(velocity.y * delta)
	target = get_global_mouse_position()

func steer(target):
	var desired_velocity = (target - self.position).normalized() * MAX_SPEED
	if mode == 0:
		pass
	elif mode == 1:
		desired_velocity = -desired_velocity
	var steer = desired_velocity - velocity
	var target_velocity = velocity + (steer * MAX_FORCE)
	return(target_velocity)

func _fov_movement(delta):
	var pos = self.position
	if mode == 0: #seek
		direction = (pos - get_global_mouse_position()).normalized()
		angle = 180 + rad2deg(direction.angle())
	elif mode == 1: #flee
		direction = (get_global_mouse_position() - pos).normalized()
		angle = 180 + rad2deg(direction.angle())

	var detect_count = 0
	for node in get_tree().get_nodes_in_group('detectable'):
		if pos.distance_to(node.position) < DETECT_RADIUS:
			var angle_to_node = rad2deg(direction.angle_to((get_global_mouse_position() - node.position).normalized()))
			if abs(angle_to_node) < FOV/2:
				detect_count += 1


	# DRAWING
	if detect_count > 0:
		draw_color = RED
	else:
		draw_color = GREEN
	update()

# Drawing the FOV
const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)

var draw_color = GREEN


func _draw():
	draw_circle_arc_poly(Vector2(), DETECT_RADIUS,  angle - FOV/2, angle + FOV/2, draw_color)


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()
    points_arc.push_back(center)
    var colors = PoolColorArray([color])

    for i in range(nb_points+1):
        var angle_point = angle_from + i*(angle_to-angle_from)/nb_points
        points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), sin( deg2rad(angle_point) ) ) * radius)
    draw_polygon(points_arc, colors)












