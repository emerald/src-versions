const nRooms <- 5
const mapW <- 20
const mapH <- 10
    const cellW <- 32
    const cellH <- 32
    const padW <- 10
    const padH <- 10
    const interfaceH <- 100

const PlayerInfo <- immutable record PlayerInfo
   goalX : Integer
   goalY : Integer
   currentX : Real
   currentY : Real
   name : String
end PlayerInfo

const Coordinates <- immutable record Coordinates
  x:Integer
  y:Integer
end Coordinates


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%% The Player Class %%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const Player <- class Player[initName : String]


                  %%%%%%%%%% Event stuff %%%%%%%%%%

  const field eq : EventQueue <- EventQueue.create


              %%%%%%%%%% Room Structure Stuff %%%%%%%%%%

  const connections
    <- Vector.of[Vector.of[Coordinates]].create[nRooms]

  const map
    <- Vector.of[Vector.of[Vector.of[Character]]].create[nRooms]

  const mapBitmap <- Vector.of[Vector.of[bitmap]].create[mapW]
  const mapAge 
    : Vector.of[VectorOfInt]
    <- Vector.of[VectorOfInt].create[mapW]



             %%%%%%%%%% World Server variables %%%%%%%%%%

  % flags
  field isWorldServer : Boolean <- False

  % constants
  const tickDelay <- Time.create[0,100000]
  const scanLimit <- 7        % No. of ticks before new scan
  const worldLimit <- 5       % No. of ticks before we become world server
  const roomLimit <- 9        % No. of ticks before we become room server
  const priorityLimit <- 50   % No. of ticks before we can change priority

  % countdowns
  field scanCountdown : Integer <- scanLimit
  field worldCountdown : Integer <- worldLimit
  field roomCountdown : Integer <- roomLimit
  field priorityCountdown : Integer <- priorityLimit
  const priorityFrequency <- 50

  % bags
  const allPlayerBag <- Bag.of[Player].create
  const allNodeBag <- Bag.of[Node].create


             %%%%%%%%%% Room Server variables %%%%%%%%%%

  const field roomServerVector
    : Vector.of[Player]
    <- Vector.of[Player].create[nRooms]
  const roomPlayerBagVector
    <- Vector.of[Bag.of[Player]].create[nRooms]
  const playerInfoBagVector
    <- Vector.of[Bag.of[PlayerInfo]].create[nRooms]


                %%%%%%%%%% Player variables %%%%%%%%%%

  field quit : Boolean <- False
  field reportEvents : Boolean <- False
  const field home : Node <- (locate aPlayer)
  field internalPriority : Integer
  field currentTick : Integer <- 0
  field name : String <- initName
  field currentRoom : Integer <- 0
  field goalX : Integer <- 0
  field goalY : Integer <- 0
  field currentX : Real <- 0.0
  field currentY : Real <- 0.0
  field justEntered : Boolean <- True

  % Interface stuff
  const myxf <- XForms.create
  field playerForm : Form
  const xFormObjectBag <- Bag.of[xFormObject].create
  field statusBitmap : bitmap
  field displayTick : Integer <- 0
  const field displayBag
    : Bag.of[Coordinates]
    <- Bag.of[Coordinates].create



                 %%%%%%%%%% Initialization %%%%%%%%%%
                 %%%%%%%%%% Initialization %%%%%%%%%%
                 %%%%%%%%%% Initialization %%%%%%%%%%

  initially


               %%%%%%%%%% Seed Randomization %%%%%%%%%%

    begin
      const seed <- home$timeofday$microseconds
      var r : Integer
      primitive "NCCALL" "RAND" "SRANDOM" [] <- [seed]
      primitive "NCCALL" "RAND" "RANDOM" [r] <- []
      aPlayer$internalPriority <- r
      aPlayer.report["New priority is " || r.asString]
    end


              %%%%%%%%%% Rooms Initialization %%%%%%%%%%

    % Read in the room connections
    const in <- inStream.fromUnix["roomStructure.bin", "r"]
    for i:Integer<-0 while i<=connections.upperBound by i<-i+1
      connections[i] <- Vector.of[Coordinates].create[nRooms]
      for j:Integer<-0 while j<=connections[i].upperBound by j<-j+1
        connections[i][j] <- Coordinates.create[in$char.ord,in$char.ord]
      end for
    end for

    % Read in the room maps
    for i:Integer<-0 while i<=map.upperBound by i<-i+1
      const newLine <- in$char
      map[i] <- Vector.of[Vector.of[Character]].create[mapH]
      for j:Integer<-0 while j<=map[i].upperBound by j<-j+1
        const newLine2 <- in$char
        map[i][j] <- Vector.of[Character].create[mapW]
        for k:Integer<-0 while k<=map[i][j].upperBound by k<-k+1
          map[i][j][k] <- in$char
        end for
      end for
    end for
    in.close

    % Initialize room stuff
    for i:Integer<-0 while i<=roomServerVector.upperbound by i<-i+1
      playerInfoBagVector[i] <- Bag.of[PlayerInfo].create
      roomPlayerBagVector[i] <- Bag.of[Player].create
      roomServerVector[i] <- Nil
    end for
    allPlayerBag.addIfUnique[aPlayer]


                %%%%%%%%%% Create Interface %%%%%%%%%%

    % set various variables
    aPlayer.report["Greetings, " || name || "!"]

    % report node info
    const nodeInfoForm <- Form.create[myxf, fl_up_box, 210, 50]
    nodeInfoForm.moveto[0, 0]
    const info <- Input.create[myxf, FL_NORMAL_INPUT, 5,5,200,40, "", Nil]
    nodeInfoForm.add[info]
    info.setInput[
      "time emx -g1m -i -Tmemory=3 -R"
      || home$name
      || ":"
      || (home$lnn/0x10000).asString
      || "\n"
    ]
    nodeInfoForm.show[fl_place_position, fl_transient, "Node info"]

    % Create the interface which consists of the map
    % and a little bear face that blinks 
    aPlayer.report["Creating interface for " || name]

    % The main form
    const windowW <- padW + mapW*cellW + padW
    const windowH <- padH + mapH*cellH + padH + interfaceH + padH
    aPlayer$playerForm <- Form.create[myxf, FL_UP_BOX, windowW, windowH]
    
    % The map
    aPlayer$playerForm.add[box.create[
      myxf, FL_DOWN_BOX,
      padW/2, padH/2,
      mapW*cellW + padW, mapH*cellH + padH, 
      ""
    ]]
    for i:Integer<-0 while i<=mapBitmap.upperbound by i<-i+1
      mapBitmap[i] <- Vector.of[bitmap].create[mapH]
      mapAge[i] <- VectorOfInt.create[mapH]
      const x <- cellW*i + padW

      for j:Integer<-0 while j<=mapBitmap[i].upperbound by j<-j+1
        const y <- cellH*j + padH
        mapBitmap[i][j] <- bitmap.create[
          myxf, FL_NORMAL_BITMAP, 
          x, y, cellW, cellH,
          ""
        ]
        mapAge[i][j] <- 3
        aPlayer$playerForm.add[mapBitmap[i][j]]
        mapBitmap[i][j].setfile[aPlayer.tile[aPlayer$currentRoom,i,j]]

        const handleMap_ij <- object handleMap_ij
          export operation CallBack [f : XFormObject]
            aPlayer.report["Map pressed: " || i.asString || "," || j.asString ]
            aPlayer$justEntered <- False
            aPlayer$goalX <- i
            aPlayer$goalY <- j
            aPlayer.sendEvent[
              roomServerVector[aPlayer$currentRoom],
              Command.playerUpdateRoom,
              Nil,
              aPlayer$currentRoom,
              aPlayer$goalX,
              aPlayer$goalY,
              aPlayer$currentX,
              aPlayer$currentY,
              aPlayer$name
            ]
          end Callback
        end handleMap_ij

        aPlayer$playerForm.add[button.create[
          myxf, FL_HIDDEN_BUTTON, 
          x, y, cellW, cellH, 
          "X", handleMap_ij
        ]]

      end for
    end for

    % The bitmap
    const x <- windowW/2 - cellW/2
    const y <- windowH - padH - interfaceH/2 - cellH
    statusBitmap <- bitmap.create[
      myxf, FL_NORMAL_BITMAP, 
      x, y, cellW, cellH,
      ""
    ]
    aPlayer$playerForm.add[statusBitmap]
    statusBitmap.setfile["bear0.bmp"]


    % The events button
    const handleEvent <- object handleEvent
      export operation CallBack [f : XFormObject]
        aPlayer$reportEvents <- !aPlayer$reportEvents
      end CallBack
    end handleEvent
    const eventW <- 80
    const eventH <- 30
    const eventX <- windowH / 4 - eventH / 2
    const eventY <- windowH - eventH - padH - eventH - padH
    aPlayer$playerForm.add[button.create[
      myxf, FL_NORMAL_BUTTON,
      eventX, eventY, eventW, eventH,
      "Event", handleEvent
    ]]

    % The report button
    const handleReport <- object handleReport
      export operation CallBack [f : XFormObject]
        statusBitmap.setLabel["Report!"]
        for i:Integer<-0 while i<3 by i<-i+1
          statusBitmap.setFile["bear1.bmp"]
          myxf.flush
          home.Delay[Time.create[0,100000]]
          statusBitmap.setFile["bear0.bmp"]
          myxf.flush
          home.Delay[Time.create[0,100000]]
        end for
        aPlayer.report["REPORT: begin"]
        aPlayer.report[
          "REPORT:   I am in room "
          || aPlayer$currentRoom.asString
        ]
        allPlayerBag.lock
        var nPlayers:Integer<-0
        loop
          const iPlayer <- allPlayerBag.advance
          exit when iPlayer==Nil
          nPlayers<-nPlayers+1
        end loop
        aPlayer.report[
          "REPORT:   "
          || nPlayers.asString
          || " player(s) in the game"
        ]
        allPlayerBag.unlock
        if aPlayer$isWorldServer then
          aPlayer.report["REPORT:   I am the World Server"]
        end if
        for i:Integer<-0 while i<=roomServerVector.upperbound by i<-i+1
          if roomServerVector[i] == aPlayer then
            aPlayer.report["REPORT:   I am Room Server " || i.asString]
            var j:Integer <- 0
            roomPlayerBagVector[i].lock
            loop
              const iPlayer <- roomPlayerBagVector[i].advance
              exit when iPlayer == Nil
              j <- j + 1
            end loop
            roomPlayerBagVector[i].unlock
            aPlayer.report[
              "REPORT:     which has " || j.asString || " player(s)"
            ]
          end if
        end for
        aPlayer.report["REPORT: end"]
      end CallBack
    end handleReport

    const reportW <- 80
    const reportH <- 30
    const reportX <- windowH / 4 - reportH / 2
    const reportY <- windowH - reportH - padH
    aPlayer$playerForm.add[button.create[
      myxf, FL_NORMAL_BUTTON,
      reportX, reportY, reportW, reportH,
      "Report", handleReport
    ]]


    % The panic button
    const handlePanic <- object handlePanic
      export operation CallBack [f : XFormObject]
        statusBitmap.setLabel["Panic!"]
        for i:Integer<-0 while i<3 by i<-i+1
          statusBitmap.setFile["bear1.bmp"]
          myxf.flush
          home.Delay[Time.create[0,100000]]
          statusBitmap.setFile["bear0.bmp"]
          myxf.flush
          home.Delay[Time.create[0,100000]]
        end for
        % redraw the map
        aPlayer$playerForm.freeze
        for i:Integer<-0 while i<=mapBitmap.upperbound by i<-i+1
          const x <- cellW*i + padW
          for j:Integer<-0 while j<=mapBitmap[i].upperbound by j<-j+1
            const y <- cellH*j + padH
            mapBitmap[i][j].setfile[aPlayer.tile[aPlayer$currentRoom,i,j]]
          end for
        end for
        aPlayer$playerForm.unfreeze
        % add ourselves back into the game
        aPlayer.broadcastEvent[
          Command.addPlayerToGame,
          aPlayer, Nil, Nil, Nil, Nil, Nil, aPlayer$name
        ]
      end CallBack
    end handlePanic

    const panicW <- 80
    const panicH <- 30
    const panicX <- windowW/2 - panicW/2
    const panicY <- windowH - panicH - padH
    aPlayer$playerForm.add[button.create[
      myxf, FL_NORMAL_BUTTON,
      panicX, panicY, panicW, panicH,
      "Panic", handlePanic
    ]]


    % The quit button
    const handleQuit <- object handleQuit
      export operation CallBack [f : XFormObject]
        statusBitmap.setLabel["Quit!"]
        for i:Integer<-0 while i<3 by i<-i+1
          statusBitmap.setFile["bear1.bmp"]
          myxf.flush
          home.Delay[Time.create[0,100000]]
          statusBitmap.setFile["bear0.bmp"]
          myxf.flush
          home.Delay[Time.create[0,100000]]
        end for
        aPlayer$quit <- True
      end CallBack
    end handleQuit

    const quitW <- 80
    const quitH <- 30
    const quitX <- 3*windowW/4 - quitW/2
    const quitY <- windowH - quitH - padH
    aPlayer$playerForm.add[button.create[
      myxf, FL_NORMAL_BUTTON,
      quitX, quitY, quitW, quitH,
      "Quit", handleQuit
    ]]


    % Show the form
    aPlayer$playerForm.show[FL_PLACE_FREE, FL_FULLBORDER, Name]
    myxf.go


                   %%%%%%%%%% eventLoop %%%%%%%%%%


    aPlayer.report["Starting Event Loop"]
    const eventLoop <- object eventLoop
      process
        loop
          exit when aPlayer$quit
          eq.waitForEvent

          if !eq.isEmpty then
            const theEvent <- eq.dequeue
            const c           <- theEvent$c
            const fromPlayer  <- view theEvent$fromPlayer as Player
            const tick        <- theEvent$tick
            const otherPlayer <- view theEvent$otherPlayer as Player
            const roomID      <- theEvent$roomID
            const dataXInt    <- theEvent$dataXInt
            const dataYInt    <- theEvent$dataYInt
            const dataXReal   <- theEvent$dataXReal
            const dataYReal   <- theEvent$dataYReal
            const dataString  <- theEvent$dataString

            if aPlayer$reportEvents then            
              aPlayer.report[
                "  processing "
                || eq$store.lowerbound.asString
                || "("
                || (eq$store.upperbound - eq$store.lowerbound + 1).asString
                || "): "
                || c.asString
              ]
            end if

            if c = Command.worldTick then
              % Do the stuff that gets triggered by a world tick:
              %   1) reset the world countdown
              %   2) check for retirement
              %   3) update our tick value
              %   4) do room server stuff
              %   5) check for our room server
              %   6) blink the bear

              % 1) reset the world countdown
              % ============================
              % If this countdown runs out, then we will assume
              % the role of world server

              aPlayer$worldCountDown <- worldLimit

              % 2) check for retirement
              % =======================
              % Retire if we are the server
              % and they have a higher priority
              % and the event was not sent from us
              % (the last one is necessary because the priorities
              % may change randomly)

              if aPlayer$isWorldServer
                & dataXInt > aPlayer$priority
                & !(fromPlayer==aPlayer)
              then
                aPlayer.report["Retiring as World Server"]
                aPlayer$isWorldServer <- False
                aPlayer$scanCountdown <- scanLimit
              end if

              % 3) update our tick value 
              % ========================
              if tick >= aPlayer$currentTick then
                aPlayer$currentTick <- tick + 1
                aPlayer$priorityCountdown <- aPlayer$priorityCountdown - 1
                
                % 4) do room server stuff
                % =======================
                for i:Integer<-0 while i<=roomServerVector.upperbound by i<-i+1
                  if roomServerVector[i]==aPlayer then

                    % We are the Room Server for room i, so 
                    % perform the room server duties

                    % For each player that we have info for
                    % room broadcast their position

                    % Create a temporary bag to collect the new
                    % player information
                    const newPlayerInfoBag <- Bag.of[PlayerInfo].create

                    playerInfoBagVector[i].lock
                    loop
                      const iPlayerInfo <- playerInfoBagVector[i].advance
                      exit when iPlayerInfo == Nil

                      const deltaX <-
                        iPlayerInfo$goalX.asReal - iPlayerInfo$currentX
                      const deltaY <-
                        iPlayerInfo$goalY.asReal - iPlayerInfo$currentY
                      const distance <- (deltaX*deltaX + deltaY*deltaY)^0.5

                      var newX : Real
                      var newY : Real

                      if distance>1.0 then 
                        newX <- iPlayerInfo$currentX + deltaX/distance
                        newY <- iPlayerInfo$currentY + deltaY/distance
                      else
                        newX <- iPlayerInfo$goalX.asReal
                        newY <- iPlayerInfo$goalY.asReal
                      end if

                      % if we're moving
                      if distance>0.0 then

                        % check to see if this this is a door
                        for j:Integer<-0 while j<nRooms by j<-j+1
                          if
                            (newX+0.5).asInteger = connections[i][j]$x
                            & (newY+0.5).asInteger = connections[i][j]$y
                          then
                            % switch rooms for player with given name
                            aPlayer.roomEvent[
                              i,
                              Command.moveToRoom,
                              Nil,
                              j,
                              connections[j][i]$x,
                              connections[j][i]$y,
                              connections[j][i]$x.asReal,
                              connections[j][i]$y.asReal,
                              iPlayerInfo$name
                            ]
                            playerInfoBagVector[i].remove[iPlayerInfo]
                          end if
                        end for

                        % check to see that this is a legal position
                        const tileString <- aPlayer.tile[
                          i,
                          (newX+0.5).asInteger,
                          (newY+0.5).asInteger
                        ]
                        if tileString="tilex.bmp" | tileString="tile#.bmp" then
                          newX <- iPlayerInfo$currentX
                          newY <- iPlayerInfo$currentY
                        end if
                      end if

                      aPlayer.roomEvent[
                        i,
                        Command.roomTick,
                        Nil,
                        i,
                        Nil,
                        Nil,
                        newX,
                        newY,
                        iPlayerInfo$name
                      ]
                      
                      newPlayerInfoBag.add[PlayerInfo.create[
                        iPlayerInfo$goalX,
                        iPlayerInfo$goalY,
                        newX,
                        newY,
                        iPlayerInfo$name
                      ]]
                      
                      playerInfoBagVector[i].remove[iPlayerInfo]

                    end loop

                    newPlayerInfoBag.reset_curr
                    loop
                      const iPlayer <- newPlayerInfoBag.advance
                      exit when iPlayer==Nil
                      playerInfoBagVector[i].add[iPlayer]
                    end loop

                    playerInfoBagVector[i].unlock


                    % Retire if someone else is in room i
                    % and we are not
                    if aPlayer$currentRoom!=i 
                      & !roomPlayerBagVector[i].empty
                      & !(roomPlayerBagVector[i].select==aPlayer)
                    then
                      aPlayer.report[
                        "Delegating Room Server "
                        || i.asString 
                        || " to a player in Room "
                        || i.asString
                      ]
                      const newRoomServer <- roomPlayerBagVector[i].select
                      aPlayer.roomEvent[
                        i,
                        Command.newRoomServer,
                        newRoomServer,
                        i,
                        aPlayer$priority, Nil, Nil, Nil, Nil
                      ]
                      roomServerVector[i] <- newRoomServer
                    end if

                  end if

                end for


                % 5) check for the room server
                % ============================
                % Check to see if we have recently gotten
                % a tick from our Room Server.

                if aPlayer$roomCountdown <= 0 
                  & !(roomServerVector[aPlayer$currentRoom] == aPlayer)
                then
                  % Our room countdown expired, so it's
                  % time to become the Room Server.
                  aPlayer.report[
                    "Hmm, no ticks from Room Server " || 
                    aPlayer$currentRoom.asString ||
                    " in a while, so become room server"
                  ]
                  aPlayer$roomCountdown <- roomLimit
                  playerInfoBagVector[aPlayer$currentRoom].add[
                    PlayerInfo.create[
                      aPlayer$goalX,
                      aPlayer$goalY,
                      aPlayer$currentX,
                      aPlayer$currentY,
                      aPlayer$name
                    ]
                  ]
                  aPlayer.broadcastEvent[
                    Command.newRoomServer,
                    aPlayer,
                    aPlayer$currentRoom,
                    aPlayer$priority, Nil, Nil, Nil, Nil
                  ]
                else
                  aPlayer$roomCountdown <- aPlayer$roomCountdown - 1
                end if


                % 6) Make the bear blink
                % ======================
                % Make the bear blink every once in a while to
                % let us know that everything's okay
                
                const blinkTick <- tick#50
                if tick#50<6 then
                  if tick#2=0 then
                     statusBitmap.setFile["bear1.bmp"]
                  else
                     statusBitmap.setFile["bear0.bmp"]
                  end if
                  statusBitmap.setLabel[""]
                  myxf.flush
                end if

              end if


            elseif c = Command.roomTick then
              % reset our tick value
              aPlayer$roomCountdown <- roomLimit

              % Check if this is our room
              if roomID=aPlayer$currentRoom then

                % update our display
                if tick>aPlayer$displayTick then

                  % new display, so remove old display stuff
                  aPlayer$playerForm.freeze
                  for i:Integer<-0 while i<=mapAge.upperBound by i<-i+1
                    for j:Integer<-0 while j<=mapAge[i].upperBound by j<-j+1
                      if mapAge[i][j]=1 then
                        mapAge[i][j] <- mapAge[i][j] + 1
                        mapBitmap[i][j].setFile[aPlayer.tile[aPlayer$currentRoom,i,j]]
%!!! I would like to add the name of the players on the map, but
% it redisplays the whole window each time I do
%                        mapBitmap[i][j].setLabel[""]
                      elseif mapAge[i][j]<1 then
                        mapAge[i][j] <- mapAge[i][j] + 1
                      end if
                    end for
                  end for
                  aPlayer$playerForm.unfreeze
                  aPlayer$displayTick <- tick

                end if

                % draw this character
                if dataString=aPlayer$name then
                  aPlayer$currentX <- dataXReal
                  aPlayer$currentY <- dataYReal
                end if
                const x <- (dataXReal+0.5).asInteger
                const y <- (dataYReal+0.5).asInteger
                mapBitmap[x][y].setFile["char"||(dataString.hash/7#8).asString||".bmp"]
%!!! I would like to add the name of the players on the map, but
% it redisplays the whole window each time I do
%                mapBitmap[x][y].setLabel[dataString]
                mapAge[x][y] <- 0
                myxf.flush
                aPlayer$displayBag.lock
                aPlayer$displayBag.add[Coordinates.create[x,y]]
                aPlayer$displayBag.unlock

              else
                aPlayer.sendEvent[
                  fromPlayer,
                  Command.removePlayerFromRoom,
                  aPlayer,
                  roomID,
                  Nil,
                  Nil,
                  Nil,
                  Nil,
                  aPlayer$name
                ]
              end if

              
            elseif c = Command.moveToRoom then
              % ignore if they're talking to someone else or we
              % just entered
              if aPlayer$name=dataString | aPlayer$justEntered then
                aPlayer.report["Been moved to room " || roomID.asString]
                aPlayer$justEntered <- True
  		aPlayer$currentRoom <- roomID
  
  		% update our display
  		aPlayer$playerForm.freeze
  		for i:Integer<-0 while i<=mapAge.upperBound by i<-i+1
  		  for j:Integer<-0 while j<=mapAge[i].upperBound by j<-j+1
  		    mapAge[i][j] <- 2
  		    mapBitmap[i][j].setFile[
  		      aPlayer.tile[aPlayer$currentRoom,i,j]
  		    ]
  		  end for
  		end for
  		aPlayer$playerForm.unfreeze

  		% update our coordinates
  		aPlayer$goalX <- dataXInt
  		aPlayer$goalY <- dataYInt
  		aPlayer$currentX <- dataXReal
  		aPlayer$currentY <- dataYReal
  
  		% inform new room server that we're here
  		aPlayer.sendEvent[
  		  roomServerVector[aPlayer$currentRoom],
  		  Command.addPlayerToRoom,
  		  aPlayer,
  		  aPlayer$currentRoom, Nil, Nil, Nil, Nil, Nil
  		]

  		% inform new room server where we are
                aPlayer.sendEvent[
                  roomServerVector[roomID],
                  Command.playerUpdateRoom,
                  Nil,
                  roomID,
                  aPlayer$goalX,
                  aPlayer$goalY,
                  aPlayer$currentX,
                  aPlayer$currentY,
                  aPlayer$name
                ]
  	      end if


            elseif c = Command.newRoomServer then
              % If we're in this room, be sure to let them
              % know that we're here
              if roomID=aPlayer$currentRoom then
                aPlayer.sendevent[
                  otherPlayer,
                  Command.addPlayerToRoom,
                  aPlayer,
                  aPlayer$currentRoom, Nil, Nil, Nil, Nil, Nil
                ]
                aPlayer.sendEvent[
                  otherPlayer,
                  Command.playerUpdateRoom,
                  Nil,
                  aPlayer$currentRoom,
                  aPlayer$goalX,
                  aPlayer$goalY,
                  aPlayer$currentX,
                  aPlayer$currentY,
                  aPlayer$name
                ]
              end if

              if roomServerVector[roomID] == aPlayer then
                % we are also the room server
                % be sure to add them to our list
                roomPlayerBagVector[roomID].lock
                roomPlayerBagVector[roomID].addIfUnique[otherPlayer]
                roomPlayerBagVector[roomID].unlock

                if !(aPlayer==fromPlayer) then
                  if dataXint >= aPlayer$priority then

                    % we are redundant, so retire
                    aPlayer.report[
                      "Retiring from Room Server " 
                      || roomID.asString
                    ]
                    roomServerVector[roomID] <- otherPlayer

                    % and send the new server
                    % our player info
                    playerInfoBagVector[RoomID].lock
                    loop
                      const iPlayerInfo <- playerInfoBagVector[RoomID].advance
                      exit when iPlayerInfo == Nil

                      aPlayer.sendEvent[
                        roomServerVector[roomID],
                        Command.playerUpdateRoom,
                        Nil,
                        roomID,
                        iPlayerInfo$goalX,
                        iPlayerInfo$goalY,
                        iPlayerInfo$currentX,
                        iPlayerInfo$currentY,
                        iPlayerInfo$name
                      ]

                    end loop
                    playerInfoBagVector[RoomID].unlock

                  else 
                    % we aren't so let everyone know that we're
                    % still the room server
                    aPlayer.report[
                      "Hey, I'm still Room Server "
                      || roomID.asString
                    ]
                    aPlayer.broadcastEvent[
                      Command.newRoomServer,
                      aPlayer,
                      roomID,
                      aPlayer$priority, Nil, Nil, Nil, Nil
                    ]

                  end if
                end if
              end if

              % Update the roomServerVector
              roomServerVector[roomID] <- otherPlayer


            elseif c = Command.addPlayerToRoom then
              aPlayer.report["Adding player to room "||roomID.asString]
              roomPlayerBagVector[roomID].lock
              roomPlayerBagVector[roomID].addIfUnique[otherPlayer]
              roomPlayerBagVector[roomID].unlock

            elseif c = Command.removePlayerFromRoom then
              aPlayer.report["Removing player from room "||roomID.asString]
              roomPlayerBagVector[roomID].lock
              roomPlayerBagVector[roomID].remove[otherPlayer]
              roomPlayerBagVector[roomID].unlock
              PlayerInfoBagVector[roomID].lock
              loop
                const iPlayerInfo <- PlayerInfoBagVector[roomID].advance
                exit when iPlayerInfo == nil
                if iPlayerInfo$name=dataString then
                  PlayerInfoBagVector[roomID].remove[iPlayerInfo]
                end if
              end loop
              PlayerInfoBagVector[roomID].unlock

            elseif c = Command.addPlayerToGame then
              allPlayerBag.lock
              allPlayerBag.addIfUnique[otherPlayer]
              allPlayerBag.unlock
              aPlayer.sendEvent[
                otherPlayer,
                Command.addMeToGame,
                Nil, Nil, Nil, Nil, Nil, Nil, Nil
              ]
              for i:Integer<-0 while i<=roomServerVector.upperbound by i<-i+1
                if roomServerVector[i]==aPlayer then
                  % let them know that we are the room server
                  aPlayer.sendEvent[
                    otherPlayer,
                    Command.newRoomServer,
                    aPlayer,
                    i,
                    aPlayer$priority, Nil, Nil, Nil, Nil
                  ]

                  % update their position if we know it
                  playerInfoBagVector[i].lock
                  loop
                    const iPlayerInfo <- playerInfoBagVector[i].advance
                    exit when iPlayerInfo == Nil
                    if iPlayerInfo$name=dataString then
                      aPlayer.sendEvent[
                        otherPlayer,
                        Command.moveToRoom,
                        Nil,
                        i,
                        iPlayerInfo$goalX,
                        iPlayerInfo$goalY,
                        iPlayerInfo$currentX,
                        iPlayerInfo$currentY,
                        iPlayerInfo$name
                      ]
                    end if
                  end loop
                  playerInfoBagVector[i].unlock
                end if
              end for

            elseif c = Command.addMeToGame then
              allPlayerBag.lock
              allPlayerBag.addIfUnique[fromPlayer]
              allPlayerBag.unlock

            elseif c = Command.removePlayerFromGame then
              allPlayerBag.lock
              allPlayerBag.remove[otherPlayer]
              allPlayerBag.unlock

            elseif c = Command.playerUpdateRoom then
              if roomServerVector[RoomID]==aPlayer then
                playerInfoBagVector[RoomID].lock
                % remove obsolete info
                loop
                  const iPlayerInfo<-playerInfoBagVector[RoomID].advance
                  exit when iPlayerInfo==Nil
                  if iPlayerInfo$name=dataString then
                    playerInfoBagVector[RoomID].remove[iPlayerInfo]
                  end if
                end loop
                % add new info
                playerInfoBagVector[RoomID].add[ PlayerInfo.create[
                  dataXInt,
                  dataYInt,
                  dataXReal,
                  dataYReal,
                  dataString
                ]]
                playerInfoBagVector[RoomID].unlock
              else
                % update them with who we think the server
                % for that room is
              end if
            else
              % unknown command!
              aPlayer.report[
                "The command "
                || c.asString
                || " has not been implemented."
              ]
            end if
          end if
        end loop
        failure
          aPlayer.report["Event loop failed!!!"]
          aPlayer.report["Event loop failed!!!"]
          aPlayer.report["Event loop failed!!!"]
        end failure
      end process
    end eventLoop


                   %%%%%%%%%% checkLoop %%%%%%%%%%

    % Depending on whether we are the world server, either:
    % 
    %   1) Perform World Server Duties or
    %   2) Check that the World Server is up
    %
    % The process of checkLoop consists of a single
    % loop with no exit clause so that the player will
    % perform the appropriate duties as long as it is 
    % in existance.

    aPlayer.report["Commencing our duties."]
    const checkLoop <- object checkLoop
      process
        loop
          exit when aPlayer$quit

          const startTime<-home$TimeOfDay
          if aPlayer$isWorldServer then


            % 1) Perform World Server duties 
            % ==============================
            % We are the World Server, so perform the various
            % World Server tasks:
            %   a. Issue a world tick to all players
            %   b. Add any new players each scanLimit ticks


               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            % a. Issue a world tick to all players
            aPlayer.broadcastEvent[
              Command.worldTick,
              Nil, Nil, aPlayer$priority, Nil, Nil, Nil, Nil
            ]

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            % b. Add new players each scanLimit ticks

% !!! maybe do some sort of inform 
% request to make sure that we
% have all the nodes

            if aPlayer$scanCountdown <= 0 then
              aPlayer$scanCountdown <- scanLimit
              const all <- home$ActiveNodes
              for i:Integer<-0 while i<=all.upperbound by i<-i+1
                allNodeBag.lock
                const contained <- allNodeBag.contains[all[i]$theNode]
                allNodeBag.unlock
                if !contained
                then
                  allNodeBag.lock
                  allNodeBag.addIfUnique[all[i]$theNode]
                  allNodeBag.unlock
  
                  const MovenPlace <- object MovenPlace
                    process
                      aPlayer.report["Adding a new player"]

                      % Move and create the player
                      fix self at all[i]$theNode
                      (locate self)$stdout.putString[
                        "What is your character's name?\n"
                      ]
                      const name <- (locate self)$stdin$string
                      const newPlayer <- Player.create[name]

                      % Update everyone else
                      aPlayer.broadcastEvent[
                        Command.addPlayerToGame,
                        newPlayer, Nil, Nil, Nil, Nil, Nil, name
                      ]
                      failure
                      end failure
                    end process
                  end MovenPlace
                end if
              end for
            else
              aPlayer$scanCountdown <- aPlayer$scanCountdown - 1
            end if


          else

            % 2) Check that the World Server is up
            % ====================================
            % If we are not the World Server, then make sure that
            % we have received a tick recently, otherwise take over
            % the job as a World Server.

            if aPlayer$worldCountdown <= 0 then

              % Our world countdown expired, so it's
              % time to become the World Server.
              aPlayer.report[
                "Hmm, no ticks from World Server in a while, so..."
              ]

              % Initialize World Server stuff
              aPlayer$isWorldServer <- True
              aPlayer$scanCountdown <- scanLimit
              aPlayer$worldCountdown <- worldLimit

% !!! maybe check to see that
% we have all the nodes

              % Empty out the obsolete bag of all nodes 
              allNodeBag.lock
              loop
                const iNode <- allNodeBag.advance
                exit when iNode == Nil
                allNodeBag.remove[iNode]
              end loop
              allNodeBag.addIfUnique[home]
              allNodeBag.unlock

              % Refill the bag of nodes
              allPlayerBag.lock
              loop
                const iPlayer <- allPlayerBag.advance
                exit when iPlayer == Nil
                begin
                  allNodeBag.addIfUnique[iPlayer$home]
                  failure
                    aPlayer.report["Couldn't locate a player"]
%                    aPlayer.removeBadPlayer[iPlayer]
                  end failure
                end
              end loop
              allPlayerBag.unlock

              if aPlayer$isWorldServer then
                aPlayer.report["I've become World Server!"]
              end if

              % write the node information to file
              const out
                <- outStream.toUnix["server." 
                || aPlayer$priority.asString,"w"]
              out.putString[
                "time emx -g1m -i -Tmemory=3 -R"
                || home$name
                || ":"
                || (home$lnn/0x10000).asString
                || "\n"
              ]
              out.close

            else
              aPlayer$worldCountdown <- aPlayer$worldCountdown - 1
            end if

          end if


          % wait until five seconds has passed from the start of the loop
          home.Delay[ tickDelay + startTime - home$timeOfDay ]
        end loop
        myxf.flush
        home.Delay[ Time.create[1,0]]
        aPlayer$playerForm.hide
        home.Delay[ Time.create[1,0]]
        myxf.die

      end process
    end checkLoop

    aPlayer.report["End of player initialization"]
  end initially


  % report
  % ======
  % Report error and status message to console
  export operation report [message : String]
    home$stdout.putString[ currentTick.asString || ":\t" || message || "\n"]
  end report




  % getPriority
  % ===========
  export operation getPriority -> [r : Integer]

%!!! maybe do something with the name as a seed
% in case two players are started at exactly the
% same time

    if aPlayer$priorityCountdown <= 0 then 
      var n : Integer
      primitive "NCCALL" "RAND" "RANDOM" [n] <- []
      if n#priorityFrequency=0 then
        primitive "NCCALL" "RAND" "RANDOM" [r] <- []
        aPlayer$internalPriority <- r
        aPlayer$priorityCountdown <- priorityLimit
        aPlayer.report["New priority is " || r.asString]
      else
        r <- aPlayer$internalPriority
      end if
    else
      r <- aPlayer$internalPriority
    end if
  end getPriority
  

  % tile
  % ====
  export operation tile [roomID:Integer, x:Integer, y:Integer] -> [r:String]
    r <- "tile" || map[aPlayer$currentRoom][y][x].asString || ".bmp"
  end tile


  % sendEvent
  % =========
  export operation sendEvent [
    toPlayer : Player,
    c : Command, 
    otherPlayer : Player,
    roomID : Integer,
    dataXInt : Integer,
    dataYInt : Integer,
    dataXReal : Real,
    dataYReal : Real,
    dataString : String
  ]

    if aPlayer$reportEvents then
      aPlayer.report["  send player: " || c.asString]
    end if

    if !(toPlayer==Nil) then

      const sendObject <- object sendObject
        process
          const e <- Event.create[
            c, 
            aPlayer,
            currentTick,
            otherPlayer,
            roomID,
            dataXInt,
            dataYInt,
            dataXReal,
            dataYReal,
            dataString
          ]
          toPlayer$eq.enqueue[e]
          failure
            aPlayer.report["Couldn't send "]
            aPlayer.report["Removing bad player"]
            aPlayer.broadcastEvent[
              Command.removePlayerFromGame,
              toPlayer,
              Nil,
              Nil,
              Nil,
              Nil,
              Nil,
              Nil
            ]
            aPlayer.report[
              "Aborted command was: "
              || c.asString
            ]
          end failure
        end process
      end sendObject

    end if
  end sendEvent




  % roomEvent
  % =========
  export operation roomEvent [
    toRoom : Integer,
    c : Command,
    otherPlayer : Player,
    roomID : Integer,
    dataXInt : Integer,
    dataYInt : Integer,
    dataXReal : Real,
    dataYReal : Real,
    dataString : String      
  ]
    
    if aPlayer$reportEvents then
      aPlayer.report["  send room: " || c.asString]
    end if
    const roomObject <- object roomObject
      process
        const e <- Event.create[
          c,
          aPlayer,
          currentTick,
          otherPlayer,
          roomID,
          dataXInt,
          dataYInt,
          dataXReal,
          dataYReal,
          dataString
        ]

        % lock the bag
        roomPlayerBagVector[toRoom].lock

        % send the event to all players
        loop
          const toPlayer <- roomPlayerBagVector[toRoom].advance
          exit when toPlayer == Nil
          
          const sendObject <- object sendObject
            process
              toPlayer$eq.enqueue[e]
              failure
                aPlayer.report[
                  "Couldn't send to one of the players in Room "
                  || toRoom.asString
                ]
                aPlayer.report["Removing bad player"]
                roomPlayerBagVector[toRoom].remove[toPlayer]
                aPlayer.broadcastEvent[
                  Command.removePlayerFromGame,
                  toPlayer,
                  Nil,
                  Nil,
                  Nil,
                  Nil,
                  Nil,
                  Nil
                ]
                aPlayer.report[
                  "Aborted command was: "
                  || c.asString
                ]
              end failure
            end process
          end sendObject
        end loop

        % unlock the bag
        roomPlayerBagVector[toRoom].unlock

        failure
          % It shouldn't fail here unless 
          % something's wrong with the bag
          % of all players.
          aPlayer.report["Couldn't send room event!"]
          aPlayer.report[
            "Aborted command was: "
            || c.asString
          ]
        end failure
      end process
    end roomObject
  end roomEvent



  % broadcastEvent
  % ==============
  export operation broadcastEvent [
    c : Command, 
    otherPlayer : Player,
    roomID : Integer,
    dataXInt : Integer,
    dataYInt : Integer,
    dataXReal : Real,
    dataYReal : Real,
    dataString : String      
  ]
    
    if aPlayer$reportEvents then
      aPlayer.report["  send all: " || c.asString]
    end if
    const broadcastObject <- object broadcastObject
      process
        const e <- Event.create[
          c,
          aPlayer,
          currentTick,
          otherPlayer,
          roomID,
          dataXInt,
          dataYInt,
          dataXReal,
          dataYReal,
          dataString
        ]


        % lock the bag
        allPlayerBag.lock


        % removePlayerFromGame is special because
        % it might result in an infinite loop
        if c = Command.removePlayerFromGame then
          allPlayerBag.remove[otherPlayer]
        end if


        % send the event to all players
        loop
          const toPlayer <- allPlayerBag.advance
          exit when toPlayer == Nil
          
          const sendObject <- object sendObject
            process
              toPlayer$eq.enqueue[e]
              failure
                aPlayer.report["Couldn't send to player on broadcast."]
                aPlayer.report["Removing bad player"]
                allPlayerBag.lock
                allPlayerBag.remove[toPlayer]
                allPlayerBag.unlock
                aPlayer.broadcastEvent[
                  Command.removePlayerFromGame,
                  toPlayer,
                  Nil,
                  Nil,
                  Nil,
                  Nil,
                  Nil,
                  Nil
                ]
                aPlayer.report[
                  "Aborted command was: "
                  || c.asString
                ]
              end failure
            end process
          end sendObject

        end loop

        % unlock the bag
        allPlayerBag.unlock

        failure
          % It shouldn't fail here unless 
          % something's wrong with the bag
          % of all players.
          aPlayer.report["Couldn't broadcast!"]
          aPlayer.report[
            "Aborted command was: "
            || c.asString
          ]
        end failure
      end process
    end broadcastObject
  end broadcastEvent



end Player

const test <- object test
  process

    (locate self)$stdout.putString["What is your character's name?\n"]
    const name <- (locate self)$stdin$String 
    const firstPlayer <- Player.create[name]

  end process
end test
