/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */

global {
	int num_of_guests <- 20;
	int num_of_inf <- 1;
	int num_fStores <- 2;
	int num_dStores <- 2;
	int num_of_WC <- 1;
	
	point inf_loc <- {50, 50};
	
	int thirst <- 0;
	int hunger <- 0;
	
	init {
		int xFPosition <- 10;
		int yFPosition <- 10;
		
		int xDPosition <- 80;
		int yDPosition <- 10;
		
		create guest number: num_of_guests;
		create inf_center number: num_of_inf{
			location <- {50, 50};
		}
		create fStore number: num_fStores{
			location <- {xFPosition, yFPosition};
			xFPosition <- 80;
			yFPosition <- 80; 
			
		}
		create dStore number: num_dStores {
			location <- {xDPosition, yDPosition};
			xDPosition <- 10;
			yDPosition <- 80;
		}
		create WC number: num_of_WC{
			location <- {90, 50};
		}
	}
}

species guest skills: [moving] {
	
	point target_point <- nil;
	int range <- 0;
	int thirst <- 0;
	int hunger <- 0;
	
	// Wander when the target point is nil(0)
	reflex be_idle when: target_point = nil{
		do wander;
	}
	
	// Learn location for the stores from the information center
	reflex learn_loc when: (hunger < 50 or thirst < 50) {
		target_point <- inf_loc;
		do goto target:target_point;
		ask inf_center at_distance range{
			if(myself.hunger < 50) {
				myself.target_point <- flip(0.5) ? self.fLocation1 : self.fLocation2;
			}
			else if(myself.thirst < 50) {
				myself.target_point <- flip(0.5) ? self.dLocation1 : self.dLocation2;
			}
		}
	}
	
	// Go to the specified target point
	reflex move_toTarget when: target_point != nil{
		do goto target: target_point;
	}
	
	
	// design
	aspect base {
		draw sphere(1.5) color: #red;
	}
	
}

species inf_center {
	
	//  Locations of 1. food stores, 2. drink stores, 3. WC
	point fLocation1 <- {10, 10};
	point fLocation2 <- {80, 80};
	
	point dLocation1 <- {80, 10};
	point dLocation2 <- {10, 80};
	
	point wcLocation <- {90, 50};
	
	
	// Design	
	aspect base {
		draw pyramid(4) color: #green;
	}
}

species fStore {
	
	
	// Design
	aspect base {
		draw cube(3) color: #purple;
	}
	
}

species dStore {
	aspect base {
		draw cube(3) color: #blue;
	}
}

species WC {
	aspect base {
		draw cube(3) color: #brown;
	}
}

experiment main {
	output {
		display map type: opengl {
			species guest aspect: base;
			species inf_center aspect: base;
			species fStore aspect: base;
			species dStore aspect: base;
			species WC aspect: base;
		}
	}
}
