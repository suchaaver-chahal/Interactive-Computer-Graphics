extends Node2D

"""
Speed Dependent Automatic Zooming

By clicking and holding the mouse down, you can navigate around the scene. 
The further from the center your mouse is, the further zoomed out the scene will be,
allowing traversal of greater distance without disorienting the user.
"""

var mouse_pos
var viewport_center
var camera_node
var mouse_pressed
var translation

# Arbitrarily set based on what feels good. Calculations are based on viewport size, so
# the same constant should work for all resolutions
var constant = 20  

var zoom
var prevZoom
var maxZoom = 5
var maximum_mouse_distance
var minZoom = 1

# Called when the node enters the scene tree for the first time.
func _ready():

	# Capture the mouse in the viewport
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

	camera_node = get_node("Camera2D")
	viewport_center = Vector2(get_viewport_rect().size.x/2 + get_viewport_rect().position.x,get_viewport_rect().size.y/2 + get_viewport_rect().position.y)
	maximum_mouse_distance = (get_viewport_rect().size - viewport_center).length()


func _input(event):
	if event is InputEventMouseButton:
		if (event.is_pressed()):
			mouse_pressed=true
		else:
			mouse_pressed=false
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# not using delta because not using physics processes
	if(mouse_pressed):

		# figure out "speed" which is really just an abuse of the distance from mouse to center
		mouse_pos = get_viewport().get_mouse_position()
		translation = (mouse_pos - viewport_center)
		var distance = translation.length()
		
		# uncomment the below line and comment out the line below that to see
		# how sudden zoom when switching direction affects the experience

		zoom = pow(maxZoom,distance/maximum_mouse_distance)
		# zoom = calcZoom(distance)
		prevZoom = zoom 
		camera_node.set_zoom(Vector2(zoom,zoom))

		# now speed is just a factor of zoom. Translation distance 
		# is divided by speed, don't want to go the whole way in one movement
		var speed = constant/zoom
		camera_node.translate((translation/speed))

func calcZoom(distance):
	# normally the idea is speed * zoom = constant, but it is better when
	# zoom scales exponentially with distance of mouse position
	var z = pow(maxZoom,distance/maximum_mouse_distance)

	# min/max zoom
	if (z < 1):
		z = 1 
	elif (z > maxZoom):
		z = maxZoom

	# Bringing mouse closer to center doesn't mean target is acquired. Could
	# mean switching directions. We don't want to have abrupt swells in zoom when
	# moving across the center of the viewport, so scale the zoom in by  a factor of 
	# the previous zoom.
	if (prevZoom && prevZoom > z):
		z = z + ((prevZoom - z)/1.025)

	return z
