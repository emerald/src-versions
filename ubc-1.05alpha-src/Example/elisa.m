const Mover <- object Mover
        initially
                const home <- locate self
                var there :     Node
                var startTime, diff : Time
                var all : NodeList
                var theElem :NodeListElement

                home$stdout.PutString["Starting on " || home$name || "\n"]
                all <- home.getActiveNodes
                home$stdout.PutString[(all.upperbound + 1).asString 
			|| " nodes active.\n"]
                startTime <- home.getTimeOfDay
                for i : Integer <- 1 while i <= 5 by i <- i + 1
                        there <- all[all.upperbound]$theNode
                        move Mover to there
                        there$stdout.PutString["Mover " || i.asString
% || "\n"
]
                        move Mover to home
                        home$stdout.PutString["Mover  " || i.asString || " " ||
home$name || "\n"]
                end for
                diff <- home.getTimeOfDay - startTime
                home$stdout.PutString["That took: " || diff.asString || "\n"]
                move Mover to there
                there$stdout.PutString["Initialized on " || there$name
% || "\n"
]
        end initially

        export operation passNothing[]
                const home <- locate self
                home$stdout.PutString["Remotely Invoked Process Here\n"]
        end passNothing

        export operation passSomething[n: ImmutableVectorOfInt]
        end passSomething
end Mover

const backOnTheRanch <- object backOnTheRanch
        process
                const home <- locate self
                var startTime, diff : Time
                const passedArray <- ImmutableVectorOfInt.create[100000]

                startTime <- home.getTimeOfDay
                home$stdout.PutString["Before Pass Nothing\n"]
                Mover.passNothing
                diff <- home.getTimeOfDay - startTime
                home$stdout.PutString["passNothing: " || diff.asString || "\n"]

                startTime <- home.getTimeOfDay
                Mover.passSomething[passedArray]
                diff <- home.getTimeOfDay - startTime
                home$stdout.PutString["passSomething: " || diff.asString
			 || "\n"]

        end process
end backOnTheRanch

