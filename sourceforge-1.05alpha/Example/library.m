const debug <- class debug
	class const stdin <- (locate self).getStdin
	class const stdout <- (locate self).getStdout
	class export operation place[s : String]
		writer.do[s]
	end place

	class export operation tmp[s:String]
		debug.place["\n" || s || "\n"]
	end tmp
end debug
const writer <- class writer
	class const stdin <- (locate self).getStdin
	class const stdout <- (locate self).getStdout
	class export operation do[s : String]
		stdout.flush
		stdout.putString[s]
		stdout.flush
	end do
end writer



const stringto <- class stringto
  class export operation Int[ s : string ] -> [i : Integer]
    var n : integer
    var ch : character

    i <- 0
    n <- s.lowerbound

    loop
      exit when n > s.upperbound

      ch <- s.getelement[n]
      exit when ch > '9'
      exit when ch < '0'

      i <- i * 10
      i <- i + ( ch.ord - '0'.ord )

      n <- n + 1
    end loop
  end Int
end stringto


export Book
const Book <- class Book [Name : String]
	field title : String <- Name
	field content : String

	export operation toString -> [s : String]
		s <- "\nTITLE: " || self$title.asString || "\n"
	end toString

	export operation sayHello
		(locate self).getStdout.putString[self.toString]
		(locate self).getStdout.flush
	end sayHello


	export operation fillup -> [s : String]
		s <- "hello"
	end fillup
		
	initially 
		if (title == "") then
			debug.tmp["\nAssigning name"]
			title <- Namer.randomTitle
		end if
		content <- self.fillup
	end initially

end Book

const BookIn <- class BookIn [b : Book]
	field title : String <- b$title
	field stock : Boolean <- TRUE
	field realbook : Book <- b
	export operation toString -> [s : String]
		s <- "TITLE: " || self$title.asString || "\n"
	end toString
end BookIn

export Library
export Driver
const Library <- class Library[d : Integer]

	class const sid : Integer <- 0
	field id : Integer <- d
	field books: Array.of[BookIn] <- Array.of[BookIn].empty
	field bookCopys : Array.of[Book] <- Array.of[Book].empty
	field libraries : Array.of[Library] <- Array.of[Library].empty


	% LOCKS
	var checkInOutLock : Lock <- Lock.create
	var addBookLock : Lock <- Lock.create
	var addLibraryLock : Lock <- Lock.create


	export operation print
		const stdout <- (locate self).getStdout
		stdout.putString["\n----------" || self$id.asString || "-------------------\n"]
		stdout.putString["ON: " || (locate self)$name || "\n"]
		stdout.putString["Library SID: " || sid.asString ||
				"\nLibrary ID: " || self$id.asString || "\n"]

		stdout.putString["Library contains: " || books.upperBound.asString || " books\n"]
		var i : Integer <- books.lowerBound
		loop
			exit when (i > books.upperBound)
			const bk <- books.getElement[i]
			stdout.putString[bk.toString]
			i <- i + 1
		end loop

		i <- libraries.lowerBound
		stdout.putString["Library knows about: " || libraries.upperBound.asString || " libraries: "]
		loop
			exit when (i > libraries.upperBound)
			const lib <- libraries.getElement[i]
			stdout.putString[lib$id.asString || " "]
			i <- i + 1
		end loop
	end print

	export operation output
		var i : Integer <- books.lowerBound
		const st <- (locate self).getStdout
		st.putString["\n"]
		loop
			exit when (i > books.upperBound)
			st.putString[books[i]$title]
			st.flush
			st.putString[", " || books[i]$realbook$title]
			st.flush
			st.putString[", " || bookCopys[i]$title || "\n"]
			st.flush
			i <- i + 1
		end loop
	end output
				

	export operation addlibBook [bok : Book]
		addBookLock.lock
		var bokin : Bookin <- BookIn.create[bok]
		self$books.addUpper[bokin]
		self$bookCopys.addUpper[bok]
		addBookLock.unlock
	end addlibBook

	export operation addLibrary [libr : Library]

		addLibraryLock.lock

		if (!self.libraryArrayFind[libr, libraries]) then
			libraries.addUpper[libr]
		end if

		addLibraryLock.unlock
	end addLibrary

	export operation checkOut [bok : BookIn] -> [result : Boolean]
		const stdout <- (locate self).getStdout
		
		checkInOutLock.lock
		if(bok !== nil) then
		if(bok$stock) then
			bok$stock <- false
			stdout.flush
			result <- true
		else
			result <- false
		end if
		end if
		checkInOutLock.unlock
			
	end checkOut

	export operation checkIn [bok : BookIn] -> [result : Boolean]
		const stdout <- (locate self).getStdout
		
		checkInOutLock.lock
		if(bok !== nil) then
		if(! bok$stock) then
			bok$stock <- true
			stdout.flush
			result <- true
		else
			result <- false
		end if
		end if
		checkInOutLock.unlock
			
	end checkIn

	export operation localSearch [qury : Query]
		const stdut <- (locate self).getstdout

		var i : Integer <- books.lowerBound
		if (qury$Title != "") then
			loop
				exit when ( i > books.upperBound)
				if (books[i]$title.str[qury.getTitle] != nil) then
					qury.addBook[books[i]$realbook$title, books[i], self]
				end if
				i <- i + 1
			end loop
		end if
	end localSearch


	
	export operation libraryArrayFind [lib : Library, LIBS : Array.of[Library]] -> [found : boolean]
		var i : Integer<- LIBS.lowerBound
		found <- false
		loop
			exit when (i>LIBS.upperBound)
			exit when (LIBS[i]$id == lib$id)
			i <- i+1
		end loop
		if(i <= LIBS.upperBound) then
			found <- true
		else
		end if
	end libraryArrayFind

	export operation BookFind [s : BookIn] 
					-> [i : Integer]
		i <- books.lowerBound
		loop
			exit when (i > books.upperBound)
			exit when (books[i]$title == s$title)
			i <- i+1
		end loop
	end BookFind
end Library









export Namer

const Namer <- class Namer 
	class const adjective <- Array.of[String].empty
	class const noun <- Array.of[String].empty
	class const titles <- Array.of[String].literal[{"Hello", "Silly", "Serious", "Rediculous", "Insane", "Lovely", "Wonderful", "Grand", "Remarkable", "Helpers", "Involuntary", "Stereotypical", "Fido", "Painting", "Fishwitch", "Minky", "Bitsy", "Quippy", "Stilted", "Lilty", "Robocop"}]
	class const sequencer <- monitor object sequencer
	  var next : Integer <- titles.lowerbound
	  export operation nextone -> [r : String]
	    r <- titles[next]
	    next <- next + 1
	    if next > titles.upperbound then
	      next <- titles.lowerbound
	    end if
	  end nextone
	end sequencer



	class export operation ranInt [max : Integer] -> [i : Integer]
%		i <- 5 %RANDOM NUMBER
	end ranInt

	

	class export operation randomTitle -> [s : String]
		s <- sequencer.nextone
	end randomTitle


	export operation randomTitle2 -> [s : String]
		s <- "random title"
	end randomTitle2
end Namer



const Reader <- class Reader [auto : boolean, d : Integer, there : Node, lib : Library]
	const sid : integer <- 0
	field automated : Boolean <- auto
	field id : integer <- d
	attached field libraries : Array.of[Library] <- Array.of[Library].empty
	attached field namr : Namer <- Namer.create
	attached field checkedOutBooks : Array.of[sourceBook] <- Array.of[SourceBook].empty
	const stdin <- (locate self).getStdin
	const stdout <- (locate self).getStdout


	initially
		self.addlibrary[lib]
		move self to there
		self.print
	end initially

	export operation print
		const stdut <- (locate self).getStdout
		stdut.putString[
			"+++++++++++++ " || self$id.asString || " ++++++++++++++\n"
			|| "Knows about " || libraries.upperBound.asString || " Libraries\n"]
		var i : Integer <- libraries.lowerBound
		loop
			exit when (i > libraries.upperBound)
			stdut.putString[libraries[i]$id.asString]
			i <- i + 1
		end loop
	end print 

	export operation addLibrary [lib : Library]
		if !(lib.libraryArrayFind[lib, libraries]) then
			libraries.addUpper[lib]
		end if
	end addLibrary

	export operation buildQuery -> [qury : Query, act: Boolean]
		const stin <- (locate self).getStdin
		const stout <- (locate self).getStdout
		qury <- Query.create[self$id]
		var str : String
		stout.putString["\nEnter Title (EXIT to end):"]
		stdout.flush
		act <- false
		str <- stin.getString
		const sss <- str.getSlice[0, str.length-1]
		if (sss = "EXIT") then
			stout.putString["Goodbye\n"]
			stout.flush
			qury <- nil
		else
			stout.putString["Searching for: " 
			|| sss]
			stout.flush
			qury.setTitle[sss]
			act <- true
		end if
	end buildQuery

	export operation buildAutoQuery ->  [qury : Query]
		const stin <- (locate self).getStdin
		const stout <- (locate self).getStdout
		qury <- Query.create[self$id]
		qury.setTitle[Namer.randomTitle]
	end buildAutoQuery


		
	export operation autoCheckOut [qury : Query]

		const stdut <- (locate self).getStdout
		var list : Array.of[SourceBook] <- qury.getBooks 
		var i : Integer <- list.lowerBound
		loop
			exit when (i > list.upperBound)
			const b <- self.realCheckOut[list, i]
			if b then
				exit
			else
				stdut.putString["\n" || qury$title || " is already checked out\n"]
				stdut.flush
%				exit
			end if
			i <- i + 1
		end loop
	end autoCheckOut

	export operation realCheckOut[list : Array.of[SourceBook], i : Integer] 
		 -> [b : Boolean]
		const stdut <- (locate self).getStdout
		const source <- list[i]$source
		const bok <- list[i]$bok
		if source.checkOut[bok] then
			stdut.putString["Checking out " || bok$title || "\n"]
			stdut.flush
			const realbook <- bok$realbook
			move realbook to (locate self)
			realbook.sayHello
			stdut.putString["\nChecked Out"]
			stdut.flush
			self$checkedOutBooks.addUpper[list[i]]
			b <- true
		else 
			b <- false
		end if
	end realCheckOut



	export operation manCheckOut [qury : Query]
		const stdut<-(locate self).getStdout
		const stdn <-(locate self).getStdin
		var list : Array.of[SourceBook]<-qury.getBooks
		var i : Integer <- list.lowerBound
		stdut.putString["\nPlease enter the number of the book you would like to check out"]
		stdut.flush
		loop
			exit when (i > list.upperBound)
			const bok <- list[i]$bok
			const lib <- list[i]$source
			stdut.putString["\n" ||
				i.asString || ": " ||
				bok$title || ", " ||
				lib$id.asString || "."]
			i <- i + 1
		end loop
		stdut.putString["\n-->"]
		stdut.flush
		const reply <- 	stringto.int[stdn.getString]
		if (reply <= list.upperBound) then
			const nothing <- self.realCheckOut[list, reply]
			if (!nothing) then
				stdut.putString["\n" || list[reply]$bok$title || " is already checked out.\n"]
			end if
		else
			stdut.putString["\nNot a valid response."]
			stdut.flush
		end if
	end manCheckOut

	export operation checkOut [qury : Query]
	
		if self$automated then
			self.autoCheckOut[qury]
		else
			self.manCheckOut[qury]
		end if

	end CheckOut

%%%%
	export operation autoCheckIn

		const stdut <- (locate self).getStdout
		const randomnumber <- 0
		const whichbook <- checkedOutBooks[checkedOutBooks.lowerbound + (randomnumber # (checkedOutBooks.upperbound - checkedOutBooks.lowerbound + 1))]
		const b <- self.realCheckIn[whichbook]
		if ! b then
			stdut.putString["\n" || whichbook$bok$title || " couldn't be checked in\n"]
			stdut.flush
		end if
	end autoCheckIn

	operation remove [b : SourceBook, list : Array.of[SourceBook]]
		assert list[list.lowerbound] == b
		const junk <- list.removeLower
	end remove

	export operation realCheckIn[b : SourceBook] -> [r : Boolean]
		const stdut <- (locate self).getStdout
		if b$source.CheckIn[b$bok] then
			const foo <- locate b$source
			const thebook <- b$bok$realbook
			move thebook to foo
			stdut.putString["\nChecking in "]
			stdut.putString[b$bok$title || "\n"]
			stdut.flush
			thebook.sayHello
			stdut.putString[b$bok$title]
			stdut.putString[" Checked In\n"]
			stdut.flush
			
			self.remove[b, checkedOutBooks]
			r <- true
		else 
			r <- false
		end if
	end realCheckIn



	export operation manCheckIn
		const stdut<-(locate self).getStdout
		const stdn <-(locate self).getStdin
		var list : Array.of[SourceBook]<- checkedOutBooks
		if list.upperbound - list.lowerbound < 0 then
			stdut.putstring["No books checked out\n"]
			return
		end if
		var i : Integer <- list.lowerBound
		stdut.putString["\nPlease enter the number of the book you would like to check in"]
		stdut.flush
		loop
			exit when (i > list.upperBound)
			const bok <- list[i]$bok
			const lib <- list[i]$source
			stdut.putString["\n" ||
				i.asString || ": " ||
				bok$title || ", " ||
				lib$id.asString || "."]
			i <- i + 1
		end loop
		stdut.putString["\n-->"]
		stdut.flush
		const reply <- 	stringto.int[stdn.getString]
		if (reply <= list.upperBound) then
			const nothing <- self.realCheckIn[list[reply]]
			if (!nothing) then
				stdut.putString["\n" || list[reply]$bok$title || " is already checked out.\n"]
			end if
		else
			stdut.putString["\nNot a valid response."]
			stdut.flush
		end if
	end manCheckIn

	export operation CheckIn
	
		if self$automated then
			self.autoCheckIn
		else
			self.manCheckIn
		end if

	end CheckIn

%%%%%
	export operation RandomNum -> [i : Integer]
		i <- 5
	end RandomNum

	export operation manualProcess
		var qury : Query <- nil

		var i : Integer <- libraries.lowerBound
		loop
		    (locate self)$stdout.putstring["Enter checkin or checkout: "]
		    (locate self)$stdout.flush
		    const input <- (locate self)$stdin.getString
		    const sss <- input.getSlice[0, input.length-1]
		    if sss = "checkout" then
			if (i > libraries.upperBound) then
				i <- libraries.lowerBound
			end if
			var act : Boolean
			qury, act <- self.buildQuery
			if (qury == nil) then
				exit
			end if
			const libr <- libraries[i]
			qury.search[libr]
			if (act) then
				self.checkOut[qury]
			end if
			i <- i + 1
		    elseif sss = "checkin" then
			self.checkIn
		    else
			(locate self)$stdout.putstring["Try again\n"]
		    end if
		end loop
		(locate self).getStdout.putString["Press ^C to end session"]
	end manualProcess

	operation random -> [n : Integer]
		primitive "NCCALL" "RAND" "RANDOM" [n] <- []
	end random

	export operation automatedProcess
		const hr <- (locate self).getStdout
		var qury : Query <- nil
		var i : Integer <- libraries.lowerBound

		loop
			const randomnumber <- self.random
			if randomnumber # 2 == 0 then
				if (i > libraries.upperBound) then
					i <- libraries.lowerBound
				end if
				qury <- self.buildAutoQuery
				var libr : Library <- nil
				libr <- libraries[i]
				qury.search[libr]
				self.checkOut[qury]
				i <- i + 1
			elseif checkedOutBooks.upperbound - checkedOutBooks.lowerbound + 1 > 0 then
				self.checkIn
			end if
			(locate self).delay[Time.create[self.random # 3, 0]]
		end loop
	end automatedProcess



	process
		if (self$automated) then
			self.automatedProcess
		else
			self.manualProcess
		end if	
	end process
end Reader

const sleeper <- class sleeper
	class export operation slp -> [s : Time]
		s <- Time.create[100,0]
	end slp
end sleeper


export Driver

const Driver <- class Driver 
	[numLibs : Integer, numBooks : Integer, numReaders : Integer]
	
	const readers <- Array.of[Reader].empty
	const librarySet <- Array.of[Library].empty
	
	const stdin <- (locate self).getStdin
	const stdout <- (locate self).getStdout

	field numLibrariesToCreate : Integer 
	field numReadersToCreate : Integer
	field numBooksToCreate : Integer

	initially 
		debug.place["About to create " || 
				numLibs.asString || " libraries, " ||
				numBooks.asString || " books, " ||
				numReaders.asString || " readers\n\n"]
		self$numLibrariesToCreate <- numLibs
		self$numReadersToCreate <- numReaders
		self$numBooksToCreate <- numBooks
	end initially

	process
		self.createLibraries
		self.activateReaders
	end process



	export operation rand [size : Integer] -> [num : Integer]
		num <- size 
	end rand



	export operation createLibraries
		var libr : Library
		var neighbor : Library
		var bok : Book
		var i, j, sz : Integer
    		var there : Node
    		var all : NodeList
    		var theElem :NodeListElement
		const home <- locate self

		home.getStdout.putString["\n\nAre you ready to begin? "]
		var dumb : String <- home.getStdin.getString

		all <- home.getActiveNodes	

		i <- librarySet.lowerBound

		var k : Integer <- all.lowerBound
		loop		
			exit when (i == numLibrariesToCreate)
			libr <- Library.create[i]
			j <- 0
			loop
				exit when (j > numBooksToCreate)
				const n <- Namer.randomTitle
				bok <- Book.create[n]
				libr.addlibBook[bok]
				j <- j+1
			end loop

			if(k > all.upperBound) then
				k <- all.lowerBound
			end if
			there <- all[k]$theNode
			k <- k + 1
			librarySet.addUpper[libr]
		
			var prev : Integer <- libr$id - 1
			if (!(prev < librarySet.lowerBound)) then
				neighbor <- librarySet.getElement[prev]
				libr.addLibrary[neighbor] 
				neighbor.addLibrary[libr]
				librarySet.setElement[libr$id, libr]
				librarySet.setElement[neighbor$id, neighbor]
			end if
			move libr to there
			i <- i+1
		end loop

		var curr : Integer <- LibrarySet.lowerBound
		loop
			exit when (curr > LibrarySet.upperBound)
			librarySet[curr].outPut
			curr <- curr+1
		end loop

	end createLibraries


	export operation activateReaders
		var libr : Library
		var sz : Integer <- librarySet.upperBound
   		var there : Node
    		var all : NodeList
    		var theElem :NodeListElement
		const home <- locate self
		all <- home.getActiveNodes


		const readr <- Reader.create[true, 0, all[2]$theNode, librarySet[0]]
		readers.addUpper[readr]
		
		const radr <- Reader.create[true, 1, all[3]$theNode, librarySet[1]]
		readers.addUpper[radr]

		const read <- Reader.create[true, 2, all[4]$theNode, librarySet[0]]
		readers.addUpper[read]

		const rad <- Reader.create[false, 2, all[5]$theNode, librarySet[1]]
		librarySet[1].output
		readers.addUpper[rad]

	end activateReaders






	
	export operation getLibrarySet -> [LibSet : Array.of[Library]]
		LibSet <- librarySet
	end getLibrarySet
	export operation setLibrarySet [lib : Library, element : Integer]
		librarySet.setElement[element, lib]
	end setLibrarySet

end Driver






export Lock
const Lock <- monitor class Lock

var free : Boolean <- true
const c : Condition <- Condition.create
export operation lock
	if !free then 
		wait c
	end if
	free <- false
end lock
export operation unlock
	free <- true
	signal c
end unlock

end Lock



const Query <- class Query [rid : Integer]
	var title : String <- ""
	const books : Array.of[SourceBook] <-  Array.of[SourceBook].empty
	const history : Array.of[Library] <- Array.of[Library].empty
	field id : Integer <- rid
	field bookCount : Integer <- 0

	%LOCKS
	var setTitleLock : Lock <- Lock.create
	var addBookLock : Lock <- Lock.create
	var addBook_getBooks : Lock <- Lock.create
	var addBook_whichLibrary : Lock <- Lock.create
	var addBook_numBooks : Lock <- Lock.create
	var addToHistory_isRecorded : Lock <- Lock.create
	var addToHistory_gtHistory : Lock <- Lock.create

	export operation setTitle [ttl : String]
		setTitleLock.lock
		title <- ttl
		setTitleLock.unlock
	end setTitle

	export operation getTitle -> [ttl : String]
		ttl <- title
	end getTitle

	export operation gtHistory -> [h : Array.of[Library]]
		addToHistory_gtHistory.lock
		h <- history
		addToHistory_gtHistory.unlock
	end gtHistory

	export operation addToHistory [lib : Library]
		addToHistory_gtHistory.lock
		addToHistory_isRecorded.lock
		history.addUpper[lib]
		addToHistory_isRecorded.unlock
		addToHistory_gtHistory.unlock
	end addToHistory

	export operation isRecorded [lib : Library] -> [b : Boolean]
		addToHistory_isRecorded.lock
		var i : Integer <- self.gtHistory.lowerBound
		b <- false
		loop
			exit when (i > self.gtHistory.upperBound)
			if (lib == self.gtHistory.getElement[i]) then
				b <- true
			end if
			i <- i + 1
		end loop

		addToHistory_isRecorded.unlock
	end isRecorded


	export operation getBooks -> [bks : Array.of[SourceBook]]
		addBook_getBooks.lock
		bks <- books
		addBook_getBooks.unlock
	end getBooks


	export operation SourceBookFind [bok:BookIn] -> [srcbook : SourceBook]
		const stdout <- (locate self).getStdout
		var i : Integer <- books.lowerBound
		stdout.flush
		loop
			exit when ( i > books.upperBound)
			exit when (books[i]$bok == bok)
			i <- i + 1
		end loop
		if (i <= books.upperBound) then
			srcbook <- books[i]
		else
			srcbook <- nil
		end if
			
	end SourceBookFind

	
	export operation addBook [s : String, bok : BookIn, source : Library]
		
		addBookLock.lock
		addBook_getBooks.lock
		addBook_whichLibrary.lock
		addBook_numBooks.lock

		if (self.SourceBookFind[bok] == nil) then 
			const sbook <- SourceBook.create[bok, source]
			books.addUpper[sbook]
			self$bookCount <- self$bookCount + 1
		end if


		addBookLock.unlock
		addBook_getBooks.unlock
		addBook_whichLibrary.unlock
		addBook_numBooks.unlock
	end addBook

	export operation whichLibrary [bok : BookIn] -> [lib : Library]
		addBook_whichLibrary.lock
		lib <- self.SourceBookFind[bok]$source
		addBook_whichLibrary.unlock
	end whichLibrary


	export operation search[libr : Library]
		self.addToHistory[libr]
		libr.localSearch[self]
		self.remoteSearch[libr]
	end search	

	export operation remoteSearch [libr : Library]
		var i : Integer <- libr$libraries.lowerBound
		loop
			exit when (i > libr$libraries.upperBound)
			var other : Library <- libr$libraries[i]
			if (!self.isRecorded[other]) then
				self.search[other]
			end if
			i <- i + 1
		end loop
	end remoteSearch

end Query



const SourceBook <- class SourceBook [b: BookIn, s: Library]
	field bok : BookIn <- b
	field source : Library <- s
end SourceBook



const main <- object main
	const stdin <- (locate self).getStdin
	const stdout <- (locate self).getStdout
	initially
		writer.do["Welcome to the Library System\n\n"]
	end initially

	process
		const drvr <- Driver.create[2, 3, 4]
	end process

end main
			

