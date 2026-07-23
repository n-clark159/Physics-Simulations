extends Control

# Slider references
@onready var radius_slider = $radiusSlider
@onready var velocity_slider = $velocitySlider
@onready var mass_slider = $massSlider

# Label references
@onready var radius_label = $radiusLabel
@onready var velocity_label = $velocityLabel
@onready var mass_label = $massLabel
@onready var force_label = $forceLabel

# Node references
@onready var ball = $Ball
@onready var pivot = $Pivot
@onready var string_line = $Line2D

# Physics Variables
var angle: float = 0.0
var angular_velocity: float = 0.0  # Speed of rotation in radians/sec
var radius: float = 100.0           # Distance from pivot
var mass: float = 1.0               # Mass of the object

func _ready():
	# Connect slider signals
	radius_slider.value_changed.connect(_on_radius_changed)
	mass_slider.value_changed.connect(_on_mass_changed)
	velocity_slider.value_changed.connect(_on_velocity_changed)
	
	# Set initial values and labels
	_update_values_from_sliders()
	_update_all_labels()

func _update_all_labels():
	mass_label.text = "%s" % mass_slider.value
	radius_label.text = "%s" % radius_slider.value
	velocity_label.text = "%s" % velocity_slider.value
	_update_force_label()

func _update_force_label():
	var linear_velocity = velocity_slider.value
	var current_radius = radius_slider.value
	var current_mass = max(mass_slider.value, 0)
	
	if current_radius > 0:
		# Centripetal Force: F = (m * v^2) / r
		var force = (current_mass * linear_velocity * linear_velocity) / current_radius
		force_label.text = "= %.2f N" % snapped(force, 0.01)
	else:
		force_label.text = "= 0 N"
		
	if current_mass > 0:
		var force = (current_mass * linear_velocity * linear_velocity) / current_radius
		force_label.text = "= %.2f N" % snapped(force, 0.01)

func _update_values_from_sliders():
	mass = max(mass_slider.value, 0.00)
	radius = radius_slider.value * 20.0
	var linear_velocity = velocity_slider.value * 30.0
	
	if radius > 0:
		angular_velocity = linear_velocity / radius

func _process(delta):
	var current_mass = max(mass_slider.value, 0.00)
	var old_angle = angle
	# Update position using angular_velocity
	angle += angular_velocity * delta
	if current_mass == 0:
		angle = old_angle
	# Position calculation
	ball.position = pivot.position + Vector2(cos(angle), sin(angle)) * radius
	
	# Draw line
	string_line.clear_points()
	string_line.add_point(pivot.position)
	string_line.add_point(ball.position)

# --- Signal Callbacks ---

func _on_radius_changed(new_value: float):
	radius_label.text = "%s" % new_value
	var new_radius = new_value * 20.0
	
	if new_radius > 0 and radius > 0:
		var current_linear_velocity = velocity_slider.value * 30.0
		angular_velocity = current_linear_velocity / new_radius

	radius = new_radius
	_update_force_label()

func _on_mass_changed(new_value: float):
	mass_label.text = "%s" % new_value
	mass = max(new_value, 0.01)
	_update_force_label()

func _on_velocity_changed(new_value: float):
	velocity_label.text = "%s" % new_value
	var linear_velocity = new_value * 30.0
	
	if radius > 0:
		angular_velocity = linear_velocity / radius
	_update_force_label()


func _on_button_button_up() -> void:
	Engine.time_scale = 0.0 
