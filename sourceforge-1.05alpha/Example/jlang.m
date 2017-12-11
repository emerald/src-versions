const my_server <- object my_server
  var home : Node
  var server_loc : Node
  var buf : String

  export operation location -> [ r : Node ]
    r <- locate self
  end location

  export operation receive[ m : Character ]
    buf <- m.asString
  end receive

  export function recv_ack[ m : Character ] -> [ r : Character ]
    buf <- m.asString	
    r <- 'a'
  end recv_ack 

  initially
    var all : NodeList

    home <- locate self
    all <- home.getActiveNodes
    server_loc <- all[2]$theNode
    home$stdout.PutString["Server about to move to " || 
			  server_loc$name || "\n"]
    fix self at server_loc
    server_loc$stdout.PutString["Arrived at " || server_loc$name || "\n"]
  end initially
end my_server

   
const my_client <- object my_client
  const home <- locate self
  var there : Node

  function send_server[ m: Character ] -> [ r: Character ]
    r <- my_server.recv_ack[ m ]
  end send_server

  process
    var startTime, diff : Time
    var recv : String
    const num <- 1000
    const mess <- 'm'    

    there <- my_server.location
    home$stdout.PutString["Server on " || there$name || "\n"]
    startTime <- home.getTimeOfDay
    for i : Integer <- 1 while i <= num by i <- i + 1
       recv <- (self.send_server[ mess ]).asString
    end for
    diff <- ( home.getTimeOfDay - startTime ) / num
    home$stdout.PutString["Received " || recv || "\n"]  
    home$stdout.PutString["Average time = " || diff.asString || "\n"]  
  end process

  initially
    home$stdout.PutString["Client on " || home$name || "\n"]
    fix self at home	
  end initially
end my_client



