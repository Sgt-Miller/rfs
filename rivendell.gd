extends Spatial

var players = {} #what are curly braces for

var issingle = false

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_to_server_ok")
	var globe = get_node("/root/global")
	
	
	if globe.issingle == true:
		host_server()
		game_setup()
		$Host.hide()
		$Join.hide()
		
	
func host_server():	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(4241, 10)
	get_tree().set_network_peer(peer)
	#checks:
	print("Hosting...This is my ID: ", str(get_tree().get_network_unique_id()))
	$Host.hide()
	$Join.hide()

func join_server():
	var peer_join = NetworkedMultiplayerENet.new()
	peer_join.create_client("127.0.0.1", 4241)
	get_tree().set_network_peer(peer_join)	
	#checks:
	print("Joining...This is my ID: ", str(get_tree().get_network_unique_id())) 
	$Host.hide()
	$Join.hide()
	
func _player_connected(id): #when someone else connects, I will register the player into my player list dictionary
	print("Hello other players. I just connected and I wont see this message!: ", id)
	#rpc("register_player", get_tree().get_network_unique_id())
	register_player(id)
#This function not needed, just to double check ID		
func _connected_to_server_ok(): 	
	print("(My eyes only)I connected to the server! This is my ID: ", str(get_tree().get_network_unique_id()))	
	#rpc("register_player", get_tree().get_network_unique_id())
#	if game_started:

remote func register_player(id): 
	print("Everyone sees this.. adding this id to your array! ", id) # everyone sees this
	#the server will see this... better tell this guy who else is already in...
	#if !(id in players):
	players[id] = ""
	
	# Server sends the info of existing players back to the new player
	if get_tree().is_network_server():
		# Send my info to the new player
		rpc_id(id, "register_player", 1) #rpc_id only targets player with specified ID
		
		# Send the info of existing players to the new player from ther server's personal list
		for peer_id in players:
			rpc_id(id, "register_player", peer_id) #rpc_id only targets player with specified ID			
		rpc("update_player_list") # not needed, just double checks everyone on same page
#Not needed, double check everyone on sme page
remote func update_player_list():
	for x in players:
		print(x)

#Not needed, double check everyone on sme page		
func update_player_list_local(): #when updatelist button is pressed
		for x in players:
			print(x)
#		if get_tree().is_network_server():
#			for x in players:
#				print(x)
		
func game_setup(): #this will setup every player instance for every player. when start game button is pressed
	$"Start".hide()
	var globe = get_node("/root/global")
	#first the host will setup the game on their end
	if get_tree().is_network_server(): 	
#		for peer_id in players:                                          
#			var player_instance = load("res://Player.tscn").instance()	
#			player_instance.set_name(str(peer_id))
#			player_instance.set_network_master(peer_id)
#			get_node("/root").add_child(player_instance)
			#player_instance.playerID = str(1) 
		
		if globe.simple == true:
			var player_instance = load("res://simple.tscn").instance()	#dont forget to add yourself  server guy!
			player_instance.set_name(str(1))
			player_instance.set_network_master(1)
			get_node("/root/Spatial").add_child(player_instance)
			player_instance.playerID = str(1) 
			
		if globe.rcam == true:
			var player_instance = load("res://rcam.tscn").instance()	#dont forget to add yourself  server guy!
			player_instance.set_name(str(1))
			player_instance.set_network_master(1)
			get_node("/root/Spatial").add_child(player_instance)
			player_instance.playerID = str(1) 
		
		if globe.simulink == true:
			var player_instance = load("res://simu.tscn").instance()	#dont forget to add yourself  server guy!
			player_instance.set_name(str(1))
			player_instance.set_network_master(1)
			get_node("/root/Spatial").add_child(player_instance)
			player_instance.playerID = str(1) 
			
		if globe.modes == true:
			var player_instance = load("res://modes.tscn").instance()	#dont forget to add yourself  server guy!
			player_instance.set_name(str(1))
			player_instance.set_network_master(1)
			get_node("/root/Spatial").add_child(player_instance)
			player_instance.playerID = str(1) 
			
	#Next evey player will spawn every other player including the server's own client! Try to move this to server only 
	for peer_id in players:
			var player_instance = load("res://smolplane.tscn").instance()	
			player_instance.set_name(str(peer_id))			
			player_instance.set_network_master(peer_id)
			get_node("/root/Spatial").add_child(player_instance)
			player_instance.playerID = str(peer_id) 
	


func _on_Back_pressed():
	var globe = get_node("/root/global")
	globe.simple = false
	globe.rcam = false
	globe.simulink = false
	globe.modes = false
	if globe.issingle:
		get_tree().change_scene("res://single.tscn")
	else:
		get_tree().change_scene("res://splash.tscn")
