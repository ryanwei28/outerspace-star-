-----------------------------------------------------------------------------------------
--設計一個派大星閃避飛彈的遊戲
--吃到甜甜圈後會增加分數以及體積
--吃甜甜圈累積能量條，集滿時進入BonusTime 
--被飛彈炸到則縮小，縮小到一定程度結束遊戲
--

--Date:2016/08/03   09:35
--Author:Ryan
-----------------------------------------------------------------------------------------

--=======================================================================================
--引入各種函式庫
--=======================================================================================
display.setStatusBar( display.HiddenStatusBar ) 
math.randomseed( os.time()) 
local physics = require("physics" ) 
physics.start( )  
physics.pause( ) 
physics.setGravity( 0 , 0) 
-- physics.setDrawMode("hybrid") 
--=======================================================================================
--宣告各種變數
--=======================================================================================
_SCREEN = {
	W = display.contentWidth ,
	H = display.contentHeight
}
_SCREEN.CENTER = {
	X = display.contentCenterX ,
	Y = display.contentCenterY
}

local star  
local bg 
local bgMusic = audio.loadStream("music/bgMusic.mp3" )  --載入背景音樂
local sound = audio.loadSound("music/swish1_2.mp3") --載入音效
local sound2 = audio.loadSound("music/laser2.mp3")
local sound3 = audio.loadSound("music/powerup.mp3")
local sound4 = audio.loadSound("music/powerdown.mp3")
local sound5 = audio.loadSound("music/gameover.mp3")
local playBgMusic 
local score = 0 
local scoreImg  
local scoreImg2
local boom  
local startBtn 
local gameover 
local continu 
local energyBar 
local emptyBar
local energyL = 0  --能量條初始長度
--=======================================================================================
--宣告各個函式名稱
--=======================================================================================
local initial
local starTouch 
local starRestore 
local moveBomb 
local addFood
local onCollision 
local addScore
local startGame
local endGame
local replay
local enterHappyTime
local bonusRestore
local startGameFirst
--=======================================================================================
--宣告與定義main()函式
--=======================================================================================
local main = function ( )
	initial()
end

--=======================================================================================
--定義其他函式
--=======================================================================================
initial = function ( )
	--執行後開啟物理引擎
	physics.start( )
	
	--加入背景圖
	bg = display.newImageRect(  "images/bg.jpg", _SCREEN.W , _SCREEN.H )
	bg.x , bg.y = _SCREEN.CENTER.X , _SCREEN.CENTER.Y
	
	--加入食物
	-- food = display.newImageRect( "images/food.png", 50, 50 )
	-- food.x , food.y = 520 , 53
	-- physics.addBody( food ,"static" , { density=0 , friction=0 , bounce=0 } )

	--加入開始按鈕
	startBtn = display.newImageRect("images/startBtn.png" ,200 , 130)
	startBtn.x ,startBtn.y = _SCREEN.W/2 , _SCREEN.H/2 
	startBtn:addEventListener( "tap", startGame )

	--加入能量條
	emptyBar = display.newImageRect("images/emptyBar.png", 140 , 30)
	emptyBar.x ,emptyBar.y = 400 , 30
	energyBar = display.newImageRect("images/energyBar.png" , energyL , 48)
	energyBar.x , energyBar.y = 330 , 32
	energyBar.anchorX = 0
end

--開啟碰撞條件
openCollision = function (  )
	star.collision = onCollision
	star:addEventListener( "collision", star )
end

--碰觸螢幕後移動球的位置以及產生變化
starTouch = function ( event)
  
	if (event.phase == "ended" or event.phase == "moved") then 
		if ( event.y >= 0 and event.y <= 107 ) then  
			transition.to(star , {time = 10  ,rotation = -30 , x = 80, y = 53.5 })
			timer.performWithDelay( 100 , function ()
				star.rotation = 0
			end )
			-- audio.play( sound2 )
		elseif ( event.y >= 107 and event.y <= 214 ) then
			transition.to(star , {time = 10 , x = 80, y = 157  })
			timer.performWithDelay( 100 , function ()
				star.rotation = 0
			end )
		elseif ( event.y >= 214 and event.y <= 321 ) then
			transition.to(star , {time = 10 , rotation = 30 , x = 80 , y = 267.5 })
			timer.performWithDelay( 100 , function ()
				star.rotation = 0
			end )
		end
	end
	
	if (event.phase == "ended") then
		audio.play( sound2 )
	end
end

--使炸彈在隨機位置產生並且移動
moveBomb = function ()
	--設置一個table在裡面取一個隨機數
	mathTable = { 1 , 2 , 3 }
	addBomb()
	--將取過的隨機數移除，則再次取得隨機數將不重複
 	table.remove( mathTable,yPosition )
 	addBomb()
end

--增加炸彈數量
addBomb = function (  )
	--加入一個隨機數並且轉換成可用的Y座標
	yPosition = math.random( 1,#mathTable )
	local bomb = display.newImageRect( "images/bomb.png", 50 , 50 )
	--讓炸彈在隨機的Y座標生成
	bomb.x , bomb.y = 490 , mathTable[yPosition]*110.5 - 57	
	bomb.id = "Bomb"
	physics.addBody( bomb,"static" , { density=0 , friction=0 , bounce=0 })
 	transition.to (bomb ,{time = 2000 , x = -40 , onComplete = function ( )
 		bomb:removeSelf( )
 	end })
 	-- bomb.isSensor = true
end

--使食物在隨機位置產生並且移動
addFood = function (  )
	yPosition2 = math.random( 1,3 )*110.5 - 57
	local food = display.newImageRect( "images/food.png", 50, 50 )
	food.x , food.y = 490 , 53
	food.id = "Food"
	physics.addBody( food ,"static" , { density=0 , friction=0 , bounce=0 } )
	food.x , food.y = 490 , yPosition2
	transition.to (food , {time = 5000 , x = -40 , onComplete = function ( )
		food:removeSelf( )
	end })
end

--增加獎勵時段食物
addBonusFood = function ()
	food2 = display.newImageRect( "images/food.png", 50, 50 )
	food2.x , food2.y = 490 , 157
	food2.id = "Food2"
	physics.addBody (food2 , "static" , { density=0 , friction=0 , bounce=0 } )
	transition.to (food2 , {time = 2000 , x = -100})
end

onCollision = function ( self , event )	
	-- print(event.other.id)
	if (event.phase == "began") then
		if (self.id =="star" and event.other.id =="Bomb") then
			event.other.isVisible = false
			event.other.isSensor = true
			star.xScale = star.xScale*0.9 
			star.yScale = star.xScale*0.9
			audio.play( sound4 )  
			local boomImg = display.newImageRect("images/boom.png" ,60 , 60 )
			boomImg.x ,boomImg.y = event.other.x , event.other.y
			transition.to( boomImg , {time = 500 , xScale=1.5 , yScale = 1.5})
			timer.performWithDelay( 510, function()
				boomImg:removeSelf()	
			end )
			if star.xScale <= 0.8 then 
				endGame()
			end
		end
		-- print( event.other.id )
		if (self.id =="star" and event.other.id =="Food2") then
			event.other:removeSelf( )
			score = score + 1000
			scoreImg2 = display.newImageRect("images/1000.png" , 70 , 50)
			scoreImg2.x ,scoreImg2.y = event.other.x , event.other.y
			transition.to( scoreImg2 , {time = 50 , xScale=1.5 , yScale = 1.5})
	 		audio.play( sound3 )
	 		timer.performWithDelay( 50, function ( )
	 			scoreImg2:removeSelf( )
	 		end )
	 	end

		if (self.id =="star" and event.other.id =="Food") then
			event.other.isVisible = false
			event.other.isSensor = true
			star.xScale = star.xScale*1.1
			star.yScale = star.xScale*1.1
			score = score + 10000
			scoreImg = display.newImageRect("images/10000.png" , 70 , 50)
			scoreImg.x ,scoreImg.y = event.other.x , event.other.y
			transition.to( scoreImg , {time = 500 , xScale=1.5 , yScale = 1.5})
			timer.performWithDelay( 510, function ()
				scoreImg:removeSelf( )
			end  )
			audio.play( sound3 )
			energyL = energyL +21
			energyBar.width = energyL
			--加入條件判斷能量條滿了以後觸發函式
			if energyL >= 140 then
				enterHappyTime()
			end
		end
	end
end

--計算分數
addScore = function (  )
	score = score + 25
	lebel_score.text =  "SCORE :".."\n".."   "..score
end

startGame = function ( )
	
	startGameFirst()

	--開始後重複播放背景音樂
	playBgMusic = audio.play( bgMusic,{ channel = 1 ,loops = -1 })
	
	--移除開始按鈕
	startBtn:removeSelf( )
	
	--加入分數標籤
	lebel_score = display.newText("SCORE :".."\n".."   "..score , 350,300,font,20)
end

--產生continu
addContinu = function (  )
	continu = display.newImageRect("images/continu.png" , 100 , 40 )
	continu.x , continu.y = 230 , 250
	continu.rotation = -20
	transition.to ( continu , { time = 500 , rotation = 10 })
	continu:addEventListener( "tap", replay )
end

--結束遊戲
endGame = function ( )
	--關閉偵聽及會產生物件的計時器
	Runtime:removeEventListener( "touch", starTouch )
	timer.cancel( tmr_score )
	timer.cancel( tmr_bomb )
	timer.cancel( tmr_food )
	star:removeSelf( )
	--產生gameover及continu圖片
	gameover = display.newImageRect("images/gameover.png" , 200 ,150)
	gameover.x , gameover.y = _SCREEN.CENTER.X , -50 
	transition.to (gameover, { time = 1000 , y = 150})
	timer.performWithDelay( 1020 , addContinu )
	--加入失敗音效
	audio.play( sound5 , {channel = 5 } )
	--暫停背景音樂並將背景音樂磁頭移到初始狀態
	audio.pause(1)
	audio.rewind(bgMusic)
end

--重新開始遊戲
replay = function ( )
	--將遊戲結束後生成物件移除，讓遊戲回到初始狀態重新開始
	continu:removeSelf( )
	gameover:removeSelf( )
	score = 0
	startGameFirst()
	--開始後重複播放背景音樂
	audio.resume(1)
	--能量條歸零
	energyL = 0
	energyBar.width = energyL
end

startGameFirst = function ( )
	
	--加入主角以及設定相關參數
	star = display.newImageRect( "images/star.png" , 100 , 100 )
	star.x , star.y = 80 , 157
	star.id = "star"
	physics.addBody( star, "dynamic", { density= 0 , friction= 1 , bounce= 1 ,radius = 25 } )
	star.isFixedRotation = true
	-- star.isSensor = true
	
	--加入延時計算分數
	tmr_score = timer.performWithDelay( 35, addScore ,-1 )
	
	--點擊螢幕上中下位置來移動主角
	Runtime:addEventListener( "touch", starTouch )
	
	--使炸彈和甜甜圈移動
	tmr_bomb = timer.performWithDelay( 900 , moveBomb , -1 )
	tmr_food = timer.performWithDelay( 5000 , addFood , -1 )
	
	-- 在bomb生成後才開啟碰撞條件
	timer.performWithDelay( 1000 , openCollision ) 
end

--進入獎勵時間5秒
enterHappyTime = function (  )
	timer.cancel( tmr_bomb )
	timer.cancel( tmr_food )

	tmr_food2 = timer.performWithDelay( 300, addBonusFood, -1 )
	-- timer.performWithDelay( 1001, openCollision2  ) 
	transition.to( energyBar, { time = 5000 , width = 0 ,onComplete = bonusRestore } )
	timer.performWithDelay( 5000 , function ()
		energyL = 0
		energyBar.width = energyL
		star.xScale = 1
		star.yScale = 1
	end )
end

--5秒後恢復成原本狀態
bonusRestore = function ( )
	tmr_bomb = timer.performWithDelay( 900 , moveBomb , -1 )
	tmr_food = timer.performWithDelay( 5000 , addFood , -1 )
	timer.cancel( tmr_food2 )

end
--=======================================================================================
--呼叫主函式
--=======================================================================================
main()

