
-- general stuff
display.setStatusBar(display.HiddenStatusBar)
local cWidth = display.contentCenterX
local cHeight = display.contentCenterY

-- physics
local physics = require("physics")
physics.start()
physics.setGravity( 0,0)

-- groups
local enemies = display.newGroup()

-- global variables
local gameActive = true
local waveProgress = 1
local numHit = 0
local shipMoveX = 0
local ship 
local speed = 6 
local shootbtn
local numEnemy = 0
local enemyArray = {}
local onCollision
local score = 0
local gameovertxt
local numBullets = 3
local ammo
local AmmoActive = true

-- global functions
local removeEnemies
local createGame
local createEnemy
local shoot
local createShip
local newGame
local gameOver
local nextWave
local checkforProgress
local createAmmo
local setAmmoOn
local backgroundMusic

--- audio
local shot = audio.loadSound ("laserbeam.mp3")
local wavesnd = audio.loadSound ("wave.mp3")
local ammosnd = audio.loadSound ("ammo.mp3")
local backgroundsnd = audio.loadStream ( "musicbackground.mp3")


	-- background
	local background = display.newImage("spacebackground.png")
	background.x = cWidth
	background.y = cHeight
	
	-- score 
	textScore = display.newText("Score: "..score, 10, 10, nil, 12)
	textWave = display.newText ("Wave: "..waveProgress, 10, 30, nil, 12)
	textBullets = display.newText ("Bullets: "..numBullets, 10, 50, nil, 12)

	-- set gamepad of the game
	local leftArrow = display.newImage("left.png")
	leftArrow.x = 30
	leftArrow.y = display.contentHeight - 30
	local rightArrow = display.newImage("right.png")
	rightArrow.x = 80
	rightArrow.y =display.contentHeight -30
	
	-- create shootbutton
	shootbtn = display.newImage("shootbutton.png")
	shootbtn.x = display.contentWidth -33
	shootbtn.y = display.contentHeight -33
	
	
	-- create gamepad
	local function stopShip(event)
		if event.phase == "ended" then
			shipMoveX = 0 
		end
	end
	

	local function moveShip(event)
		ship.x = ship.x + shipMoveX
	end
	

	function leftArrowtouch()
		shipMoveX = - speed
	end
	

	function rightArrowtouch()
		shipMoveX = speed
	end
	
	
	local function createWalls(event)	
		if ship.x < 0 then
			ship.x = 0
		end
		if ship.x > display.contentWidth then
			ship.x = display.contentWidth
		end
	end
	
function createShip()
	ship = display.newImage ("ship.png")
	physics.addBody(ship, "static", {density = 1, friction = 0, bounce = 0});
	ship.x = cWidth
	ship.y = display.contentHeight - 80
	ship.myName = "ship"
end

function createEnemy()
	numEnemy = numEnemy +1 

	print(numEnemy)
			enemies:toFront()
			enemyArray[numEnemy]  = display.newImage("enemy.png")
			physics.addBody ( enemyArray[numEnemy] , {density=0.5, friction=0, bounce=0})
			enemyArray[numEnemy] .myName = "enemy" 
			startlocationX = math.random (0, display.contentWidth)
			enemyArray[numEnemy] .x = startlocationX
			startlocationY = math.random (-500, -100)
			enemyArray[numEnemy] .y = startlocationY
		
			transition.to ( enemyArray[numEnemy] , { time = math.random (12000, 20000), x= math.random (0, display.contentWidth ), y=ship.y+500 } )
			enemies:insert(enemyArray[numEnemy] )
end

function createAmmo()
	
		ammo = display.newImage("ammo.png")
		physics.addBody ( ammo,  {density=0.5, friction=0, bounce=0 })
		ammo.myName = "ammo" 
		startlocationX = math.random (0, display.contentWidth)
		ammo .x = startlocationX
		startlocationY = math.random (-500, -100)
		ammo .y = startlocationY
		
		transition.to ( ammo, {time = math.random (5000, 10000 ), x= math.random (0, display.contentWidth ), y=ship.y+500 } ) 
	
		local function rotationAmmo ()
		ammo.rotation = ammo.rotation + 45
		end

		rotationTimer = timer.performWithDelay(200, rotationAmmo, -1)
		
		
end

	function shoot(event)
		
		if (numBullets ~= 0) then
			numBullets = numBullets - 1
			local bullet = display.newImage("bullet.png")
			physics.addBody(bullet, "static", {density = 1, friction = 0, bounce = 0});
			bullet.x = ship.x 
			bullet.y = ship.y 
			bullet.myName = "bullet"
			textBullets.text = "Bullets "..numBullets
			transition.to ( bullet, { time = 1000, x = ship.x, y =-100} )
			audio.play(shot)
		end 
		
	end
 

function onCollision(event)
	if(event.object1.myName =="ship" and event.object2.myName =="enemy") then	
			
			
			local function setgameOver()
			gameovertxt = display.newText(  "Game Over", cWidth-110, cHeight-100, "Arcade", 50 )
			gameovertxt:addEventListener("tap",  newGame)
			end
			-- use setgameover after transition complete to avoid that user clicks gameover before the transition is completed
			transition.to( ship, { time=1500, xScale = 0.4, yScale = 0.4, alpha=0, onComplete=setgameOver  } )
			gameActive = false
			removeEnemies()
			audio.fadeOut(backgroundsnd)
			audio.rewind (backgroundsnd)
			
	end	
	
	if(event.object1.myName =="ship" and event.object2.myName =="ammo") then
		local function sizeBack()
		ship.xScale = 1.0
		ship.yScale = 1.0 
		
		end
		transition.to( ship, { time=500, xScale = 1.2, yScale = 1.2, onComplete = sizeBack  } )
		numBullets = numBullets + 3 
		textBullets.text = "Bullets "..numBullets
		event.object2:removeSelf()
		event.object2.myName=nil
		timer.cancel(rotationTimer)
		audio.play(ammosnd)
		
	end

	if((event.object1.myName=="enemy" and event.object2.myName=="bullet") or 
		(event.object1.myName=="bullet" and event.object2.myName=="enemy")) then
			event.object1:removeSelf()
			event.object1.myName=nil
			event.object2:removeSelf()
			event.object2.myName=nil
			score = score + 10
			textScore.text = "Score: "..score
			numHit = numHit + 1
			print ("numhit "..numHit)
			end
	
	
end

function removeEnemies()
	for i =1, #enemyArray do
		if (enemyArray[i].myName ~= nil) then
		enemyArray[i]:removeSelf()
		enemyArray[i].myName = nil
		end
	end
end


function newGame(event)	
		display.remove(event.target)	
		textScore.text = "Score: 0"
		numEnemy = 0
		ship.alpha = 1
		ship.xScale = 1.0
		ship.yScale = 1.0
		score = 0
		gameActive = true
		waveProgress = 1	
		backgroundMusic()
		numBullets = 3
		textBullets.text = "Bullets "..numBullets
		AmmoActive = true
end

function nextWave (event)
	display.remove(event.target)
	numHit = 0
	gameActive = true 
end

function setAmmoOn()
		AmmoActive = true
end

function ammoStatus()
	
	if gameActive then
		createEnemy()
		if AmmoActive then
			if (numBullets == 0) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 1) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 2) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 4) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
		end
	end

	
end


local function checkforProgress()
		if numHit == waveProgress then
			gameActive = false
			audio.play(wavesnd)
			removeEnemies()
			waveTxt = display.newText(  "Wave "..waveProgress.. " Completed", cWidth-80, cHeight-100, nil, 20 )
			waveProgress = waveProgress + 1
			textWave.text = "Wave: "..waveProgress
			print("wavenumber "..waveProgress)
			waveTxt:addEventListener("tap",  nextWave)
end
	
	-- remove enemies which are not shot
	
	for i =1, #enemyArray do
		if (enemyArray[i].myName ~= nil) then
			if(enemyArray[i].y > display.contentHeight) then
			    enemyArray[i]:removeSelf()
			    enemyArray[i].myName = nil
				score = score - 20 
				textScore.text = "Score: "..score
				warningTxt = display.newText(  "Watch out!", cWidth-42, ship.y-50, nil, 12 )
					local function showWarning()
					display.remove(warningTxt)
					end
				timer.performWithDelay(1000, showWarning)
				print("cleared")
		end
		end
	end
end

-- play background music
function backgroundMusic()
	audio.play (backgroundsnd, { loops = -1})
	audio.setVolume(0.5, {backgroundsnd} ) 	
end

-- heart of the game
function startGame()
createShip()
backgroundMusic()

shootbtn:addEventListener ( "tap", shoot )
rightArrow:addEventListener ("touch", rightArrowtouch)
leftArrow:addEventListener("touch", leftArrowtouch)
Runtime:addEventListener("enterFrame", createWalls)
Runtime:addEventListener("enterFrame", moveShip)
Runtime:addEventListener("touch", stopShip)
Runtime:addEventListener("collision" , onCollision)

timer.performWithDelay(5000, ammoStatus,0)
timer.performWithDelay ( 5000, setAmmoOn, 0 )
timer.performWithDelay(300, checkforProgress,0)

end

startGame()
