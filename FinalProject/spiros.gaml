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
	point infLloc <- {50, 50};
	point wcLoc  <- {rnd(1, 90), rnd(1, 90)};
	point restPlaceLoc <- {rnd(1, 90), rnd(1, 90)};
	point cellLoc <- {rnd(1, 90), rnd(1, 90)};

	
	
	init {
		create guest number:number_of_guests{
			location <- starting_point;
		}
		create cop number:1{
			
		}
		create cleaner number:1{
			
		}
		create stageManager number:1{
			
		}
		
		create entertainer number:1{
			
		}
		
		create entrance {
			location <- {100, 50};
		}
		
		create infoCenter {
			location <- {50, 50};
		}
		
		create store1 number:1{
			location <- store1Loc;
		}
		create store2 number:1{
			location <- store2Loc;
		}
		create wc number:1{
			location <- wcLoc;
		}
		create restPlace number:1{
			location <- restPlaceLoc;
		}
		create cell number:1{
			location <- cellLoc;
		}
	}
	
}

species guest skills: [moving, fipa] {
	point target_point <- nil;
	bool arrived <- false;
	bool wandering <- true;
	bool planning <- false;
	bool reacting <- false;
	bool modelling <-false;
	list curious;
	
	reflex control when: planning {
		add guest to: curious;
		do goto target: infLloc ;
		wandering<-false;
	}
	
	reflex atPark when: (!arrived or wandering) {
		do wander;
		arrived <-true;
		planning <- flip(0.1);
	}
	
	aspect basic {
		draw pyramid(3) color: #red;
	}
}
species cop {
	
	aspect basic {
		draw pyramid(3) color: #blue;
	}
}
species cleaner {
	
	aspect basic {
		draw pyramid(3) color: #green;
	}
}
species stageManager {
	
	aspect basic {
		draw pyramid(3) color: #orange;
	}
}
species entertainer {
	
	aspect basic {
		draw pyramid(3) color: #pink;
	}
}
species infoCenter {
	
	reflex askGuest {
		ask guest at_distance 2 {
			if length(self.curious)>0{
			 	loop c over: curious {
					write "what are you looking for";	
					// ACTIONS
			
					remove self.curious[0] from: self.curious;
				}
			}
			
			
		}
	
	}
	
	
	
	
	aspect basic {
		draw cube(4) color: #purple;
	}
}
species store1 {
	
	aspect basic {
		draw cube(4) color: #blue;
	}
}
species store2 {
	
	aspect basic {
		draw cube(4) color: #blue;
	}
}

species wc {
	
	aspect basic {
		draw cube(4) color: #brown;
	}
}

species restPlace {
	
	aspect basic {
		draw cube(4) color: #teal;
	}
}
species cell {
	
	aspect basic {
		draw cube(4) color: #black;
	}
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
			species cop aspect: basic;
			species cleaner aspect: basic;
			species stageManager aspect: basic;
			species entertainer aspect: basic;
			species entrance aspect: basic;
			species infoCenter aspect: basic;
			species store1 aspect: basic;
			species store2 aspect: basic;
			species wc aspect: basic;
			species restPlace aspect: basic;
			species cell aspect: basic;
		}
		
		
	}
}
