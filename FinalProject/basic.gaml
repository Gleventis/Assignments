/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */

global {
	int number_of_guests <- 5;
	point starting_point <- {100, 50};
	point store1Loc <- {rnd(1, 90), rnd(1, 90)};
	point store2Loc <- {rnd(1,90), rnd(1,90)};
	
	init {
		create guest number:number_of_guests{
			location <- starting_point;
		}
		
		create entrance {
			location <- {100, 50};
		}
		
		create infoCenter {
			location <- {50, 50};
		}
	}
	
}

species guest skills: [moving, fipa] {
	point target_point <- nil;
	bool arrived <- false;
	bool wandering <- true;
	
	reflex atPark when: (!arrived or wandering) {
		do wander;
		arrived <- true;
	}
	
	aspect basic {
		draw pyramid(3) color: #red;
	}
}


species infoCenter {
	
	
	
	aspect basic {
		draw cube(4) color: #purple;
	}
}

species store {

}

species entrance {
	
	aspect basic {
		draw circle(10) color: #green;
	}
}

experiment main {
	output {
		display my_display type: opengl {
			species guest aspect: basic;
			species entrance aspect: basic;
			species infoCenter aspect: basic;
		}
		
		
	}
}
