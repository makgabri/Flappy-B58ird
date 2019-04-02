# Bird Modules

### Description
The initial plan of creating a bird was to attempt to use a step by step to determine the birds movement:
1. Start bird at middle of y length but fixed x(possible 20 pixels from the left)
2. When go is pressed start the bird's movement
3. Natural state is falling state, bird drops by "gravity value" where gravity value is double every clock cycle
4. When go is pressed change state to flap state and jump bird by "n" pixels up", reset gravity value
5. When drawing, we will always have a y value, use this value to check with pipes array and see if it there exists data there, if yes then game ends and goes back to state 1, otherwise continue to flap wait state
6. Flap wait state is the same as falling state but purpose is so that the user cannot hold "go" to keep flying, this mimicks birds motion of jumping


### Process
Came across many issues that slowed process. Original code was in bird.v where we attempted to draw some code to use LED's to mimick the bird's y movement  
Issues:  
    - FSM wasn't working  
Possible reasons for issues:  
    - Clock cycle was modified to be slower, maybe the clock cycle was not working properly(not 1 clock cycle per second)  
    - We want to perform an action based on a button "go" but when clock cycle is slower, go might be pressed in the middle of a negative edge and let go while still on negative edge so signal was never recieved  
Possible fixes:  
    - Fix a clock cycle to make the visuals to change every 0.5 second  
    - Use clock50 to check for "go" movement and set a variable to inform the drawer that we want to go to another state.  
    - Make sure clock cycle is actually working  
  
We then remodified code into birdModule.v, with a better understand we wanted to save time instead of trying to debug leds we wanted to staight up draw the bird. BirdModule.v uses an iterator to draw 4x4 blocks representing the bird. It involves steps to attempt to draw black over the bird to make it look like it flew.  
Issues:  
    - FSM seemed to work but clock cycle still seemed too fast, we used hex display to show state in fsm and used key to try to switch between states but it seemed too fast to actually do anything but we continued  
    - When trying to draw, even though its looping in the same state, its not iterating through the pixel counter and only draws one pixel on the vga  
    - Cannot continue to draw bird given that it doesnt even draw the first state possible  
Possible reasons for issues:  
    - Clock is drawing to fast or going too fast to properly go through each state  
    - code for vga is not correct  
Possible fixes:  
    - Implement a way to use clock 50 to see go and modify a variable for fsm to decide the next state  
    - If all is still not working, ignore the flap wait state and draw a bird the has constant speed. It goes down at constant speed, goes up at constant speed and  is controlled by go  
    - To show more progress, make sure keyboard works, code is copied and is very straightforward to implement  
### Next Step
Added comments to mainWithBird.v to decide how to implement code for it to work
