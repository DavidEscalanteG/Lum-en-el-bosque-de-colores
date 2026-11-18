extends CanvasLayer

# 1. Referencias a los elementos de tu interfaz
@onready var usuario_input: LineEdit = $UsuarioInput
@onready var password_input: LineEdit = $PasswordInput
@onready var mensaje_error: Label = $MensajeError
@onready var boton_accion: Button = $BotonAccion
@onready var boton_cambiar_modo: Button = $BotonCambiarModo

# Archivo local donde se guardarán los usuarios de forma permanente
const RUTA_GUARDADO = "user://usuarios_data.cfg"
var config = ConfigFile.new()

# Control de estado: false = Registro, true = Login
var es_modo_login: bool = false

func _ready() -> void:
	mensaje_error.text = ""
	_cargar_usuarios()
	
	# Iniciamos la interfaz en modo Registro por defecto
	_actualizar_interfaz()
	
	# Conexión de señales por código
	boton_accion.pressed.connect(_on_boton_accion_pressed)
	boton_cambiar_modo.pressed.connect(_on_cambiar_modo_pressed)

# --- CAMBIO DE MODO (REGISTRO <-> LOGIN) ---

func _on_cambiar_modo_pressed() -> void:
	es_modo_login = !es_modo_login
	usuario_input.text = ""
	password_input.text = ""
	_actualizar_interfaz()

func _actualizar_interfaz() -> void:
	if es_modo_login:
		boton_accion.text = "Entrar"
		boton_cambiar_modo.text = "¿No tienes cuenta? Regístrate aquí"
		_mostrar_mensaje("Bienvenido, ingresa tus datos", Color.WHITE)
	else:
		boton_accion.text = "Registrar"
		boton_cambiar_modo.text = "Ya tengo una cuenta, quiero entrar"
		_mostrar_mensaje("Crea un nuevo usuario y contraseña", Color.WHITE)

# --- LÓGICA PRINCIPAL ---

func _on_boton_accion_pressed() -> void:
	var user = usuario_input.text
	var password = password_input.text
	
	if user == "" or password == "":
		_mostrar_mensaje("Por favor, llena todos los campos.", Color.YELLOW)
		return

	if es_modo_login:
		_ejecutar_login(user, password)
	else:
		_ejecutar_registro(user, password)

# --- PROCESO DE REGISTRO ---

func _ejecutar_registro(user: String, password: String) -> void:
	if config.has_section_key("usuarios", user):
		_mostrar_mensaje("Error: Este usuario ya existe.", Color.RED)
	else:
		# Guardamos en el archivo ConfigFile
		config.set_value("usuarios", user, password)
		config.save(RUTA_GUARDADO)
		
		# Feedback visual solicitado
		_mostrar_mensaje("Te has registrado exitosamente", Color.CYAN)
		usuario_input.text = ""
		password_input.text = ""
		
		await get_tree().create_timer(1.5).timeout
		
		# Pasamos a modo Login automáticamente
		es_modo_login = true
		_actualizar_interfaz()
		_mostrar_mensaje("Introduce tu nombre y contraseña para entrar", Color.YELLOW)

# --- PROCESO DE LOGIN ---

func _ejecutar_login(user: String, password: String) -> void:
	if config.has_section_key("usuarios", user):
		var pass_guardada = config.get_value("usuarios", user)
		
		if pass_guardada == password:
			_mostrar_mensaje("¡Acceso concedido!", Color.GREEN)
			await get_tree().create_timer(1.0).timeout
			# Cambia a la escena principal de tu juego
			get_tree().change_scene_to_file("res://menu1.tscn")
		else:
			_mostrar_mensaje("Contraseña incorrecta.", Color.RED)
	else:
		_mostrar_mensaje("El usuario no existe.", Color.RED)

# --- FUNCIONES AUXILIARES ---

func _cargar_usuarios() -> void:
	var err = config.load(RUTA_GUARDADO)
	if err != OK:
		print("Archivo de usuarios nuevo creado.")

func _mostrar_mensaje(texto: String, color: Color) -> void:
	mensaje_error.add_theme_color_override("font_color", color)
	mensaje_error.text = texto
