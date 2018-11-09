/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */

global {
	int num_of_guests <- 2;
	int num_of_inf <- 1;
	int num_fStores <- 2;
	int num_dStores <- 2;
	int num_of_WC <- 1;

	
	point inf_loc <- {50, 50};

	
	init {
		int xFPosition <- 10;
		int yFPosition <- 10;
		
		int xDPosition <- 80;
		int yDPosition <- 10;
		
		create guest number: num_of_guests {
			
		}
		
		create info_center number: num_of_inf{
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
	int thirst <- 0;
	int hunger <- 0;
	int range <- 40;
	int small_range <- 5;
	bool atInfCenter <- false;
	bool atFStore <- false;
	bool atDStore <- false;
	
		// Wander when the target point is nil(0)
	reflex be_idle when: target_point = nil{
		do wander;
		
	}
	
	reflex hungrythirsty {
		write(name + ":hunger--> " + hunger + ", thirst--> " + thirst);
	}
	
	reflex infocenter{
		if(target_point = nil) {
			write(name + " heading to the info center.");
		}
	}
	
	
	reflex learnLocs when: ((hunger = 0 or thirst = 0) and atInfCenter = false) {
		do goto target: inf_loc;
		ask info_center {
			if (myself.hunger = 0 and myself.location = inf_loc) {
				myself.target_point <- flip(0.5) ? self.fLocation2 : self.fLocation1;
				write("MPHKA");
				myself.atInfCenter <- true;
				myself.atFStore <- true;
			}
			else if(myself.thirst = 0 and myself.location = inf_loc) {
				myself.target_point <- flip(0.5) ? self.dLocation1 : self.dLocation2;
				write("MPHKA PALI");
				myself.atInfCenter <- true;
				myself.atDStore <- true;
			}
		}
	}                    
	
	reflex atStore when: (atFStore = true or atDStore = true) {
		if (atFStore = true) {
			do goto target: target_point;
			if (location = target_point) {		
			hunger <- 5;
			atFStore <- false;	
			}
		}
		else if (atDStore = true) {
			atDStore <- false;
			thirst <- 5;
		}
		write(name + " hunger : " + hunger + " thirst: " + thirst);
	}
	
	reflex askWC when: (hunger = 5 or thirst = 5) {
		if(hunger = 5 or thirst = 5 ) {
			write(name + " have to pee");
			do goto target: inf_loc;
			ask info_center{
				if((myself.hunger = 5 or myself.thirst = 5) and myself.location = inf_loc) {
					myself.target_point <- self.wcLocation;
				}
			}
		}
	}
	
	reflex wc when: (hunger = 5 or thirst = 5) {
		do goto target: target_point;
		hunger <- 0;
		thirst <- 0;
	}
	
		// Go to the specified target point
	reflex move_toTarget when: target_point != nil{
		write(name + " PAW STO TARGET MOY: " + target_point);
		do goto target: target_point.location;
	}
	
	// design
	aspect base {
		draw sphere(1.5) color: #red;
	}
	
}

species info_center {
	
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
			species info_center aspect: base;
			species fStore aspect: base;
			species dStore aspect: base;
			species WC aspect: base;
		}
	}
}
