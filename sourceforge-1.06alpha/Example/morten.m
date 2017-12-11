const program10 <- object main
        function potens [tal : real,pot : integer] -> [res : real]
                if pot=0 then
                        res <- 1.0
                else
                        res <- tal*self.potens[tal,pot-1]
                end if
        end potens

        process
                loop

                        var tal : real
                        var pot : integer
                        stdout.putstring["Indtast tal :\n"]
                        tal <- real.literal[stdin.getstring]
                exit when tal=0.0
                        stdout.putstring["Indtast potens :\n"]
                        pot <- integer.literal[stdin.getstring]

                        stdout.putstring["Resultatet er: \n" ||
                                self.potens[tal,pot].asstring || "\n\n"]
                end loop
        end process
end main
