const myobject <-  object myobject
	export operation donothing
		%const here <- locate self
		%here$stdout.PutString["aa\n"]
	end donothing
	export operation dosomething[m: ImmutableVector.Of[Character]]
		%const here <- locate self
		%here$stdout.PutString[m.getElement[99].asString || "\n"]
	end dosomething
end myobject

const invoke <- object invoke
	process
		const home <- locate self
		const doit <- myobject
                %var  m : immutable object VectorOfChar
		var there :     Node
    		var startTime, diff, meanT: Time
    		var all : NodeList
    		var theElem :NodeListElement
		var  m: ImmutableVector.Of[Character] <- ImmutableVector.Of[Character].create[16000]
		var timeArray: Vector.Of[time] <- Vector.Of[time].create[100]
		var mean, temp, totsqr, variance, std, thrput : Real <- 0.0

		home$stdout.PutString["Starting on " || home$name || "\n"]
    		all <- home.getActiveNodes
		home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
		there <- all[1]$theNode

		%Moving object
		startTime <- home.getTimeOfDay
    		move doit to there
		diff <- home.getTimeOfDay - startTime
		home$stdout.PutString["Time to move an object from one machine to another= " || diff.asString || "ms\n\n\n"]


		%invocation with no parameters
		for i: Integer <- 0 while i<= 99 by i <- i+1
			startTime <- home.getTimeOfDay
			doit.donothing
			timeArray[i] <- home.getTimeOfDay - startTime
		end for
		meanT <- timeArray[0]
		for i: Integer <- 1 while i < 100 by i <- i+1
			meanT <- meanT + timeArray[i]
		end for
		meanT <- meanT / 100
		mean <- meanT.getSeconds.asReal + meanT.getMicroseconds.asReal/1000000.0
		%meanT <- meanT * 1000    % convert into millisecondsdiff <- me%an * 1000
		totsqr <- 0.0
		for i: Integer <- 0 while i<=99 by i<- i+1
			temp <- timeArray.getElement[i].getSeconds.asReal + timeArray[i].getMicroseconds.asReal/1000000.0
			totsqr <- totsqr + (temp-mean)*(temp-mean)
		end for
		variance <- totsqr/99.0
		std <- variance ^ 0.5
    		home$stdout.PutString["Remote Invocation with no Parameters\n"]
		home$stdout.PutString["Mean Time = " || meanT.asString ||
"s\n"]
		home$stdout.PutString["Variance = " || variance.asString ||
"s\n"]
		home$stdout.PutString["STD = " || std.asString || "s\n\n\n"]



		%for invocation with a large parameter
		%m.setElement[99999, 'c']
		for i: Integer <- 0 while i<= 99 by i <- i+1
			startTime <- home.getTimeOfDay
			doit.dosomething[m]
			timeArray.setElement[i, (home.getTimeOfDay - startTime)]
		end for
		meanT <- timeArray.getElement[0]
		for i: Integer <- 1 while i <= 99 by i<- i+1
			meanT <- meanT + timeArray.getElement[i]
		end for
		meanT <- meanT / 100

		mean <- meanT.getSeconds.asReal + meanT.getMicroseconds.asReal/1000000.0
		%meanT <- meanT * 1000    % convert into millisecondsdiff <- me%an * 1000
		thrput <- 16.0/mean
		totsqr <- 0.0
		for i: Integer <- 0 while i<=99 by i<- i+1
			temp <- timeArray.getElement[i].getSeconds.asReal + timeArray[i].getMicroseconds.asReal/1000000.0
			totsqr <- totsqr + (temp-mean)*(temp-mean)
		end for
		variance <- totsqr/99.0
		%std <- variance ^ 0.5
    		home$stdout.PutString["Remote Invocation with 16KB string Parameter\n"]
		home$stdout.PutString["Mean Time = " || meanT.asString || "s\n"]
		home$stdout.PutString["Variance = " || variance.asString || "s\n"]
  		home$stdout.PutString["STD = " || std.asString || "s\n"]
		home$stdout.PutString["Throughput = " || thrput.asString || "KB/sec\n"]
	end process
end invoke
