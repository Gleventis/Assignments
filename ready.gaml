/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/
 model basic
 /* Insert your model definition here */
 global {
	int num_of_guests <- 5;
	int num_of_inf <- 1;
	int num_fStores <- 2;
	int num_dStores <- 2;
	int num_of_WC <- 1;
	int num_of_guards <- 1;
 	
	point inf_loc <- {50, 50};
 	
	init {
		int xFPosition <- 10;
		int yFPosition <- 10;
		
		int xDPosition <- 80;
		int yDPosition <- 10;
		
		create guest number: num_of_guests {
			
		}
		
		create guard number: num_of_guards {
			
		}
		
		create info_center number: num_of_inf {
			location <- {50, 50};
		}
		
		create fStore number: num_fStores {
			location <- {xFPosition, yFPosition};
			xFPosition <- 80;
			yFPosition <- 80; 
			
		}
		create dStore number: num_dStores {
			location <- {xDPosition, yDPosition};
			xDPosition <- 10;
			yDPosition <- 80;
		}
		
		create WC number: num_of_WC {
			location <- {90, 50};
		}
	}
}
 species guest skills: [moving] {
	
	point target_point <- nil;
	int thirst <- 0;
	int hunger <- 0;
	bool atInfCenter <- false;
	bool atInfCenter2 <- false;
	bool atInfCenter3 <- false;
	bool atFStore <- false;
	bool atDStore <- false;
	bool atWC <- false;
	bool bad <- flip(0.2);
	rgb color <- flip(0.5)? #red :#blue;
	
		// Wander when the target point is nil(0)
	reflex be_idle when: target_point = nil {
		do wander;
		
	}
	
	reflex hungrythirsty {
		write(name + ":hunger--> " + hunger + ", thirst--> " + thirst);
	}
	
	reflex infocenter {
		if(target_point = nil) {
			write(name + " heading to the info center.");
		}
	}
	
	
	reflex learnLocs when: (target_point = nil and atInfCenter = false) {
		do goto target: inf_loc;
		ask info_center {
			if (myself.hunger < 5 and myself.location = inf_loc and (myself.color = #red or myself.color = #grey)) {
				myself.target_point <- flip(0.5) ? self.fLocation2 : self.fLocation1;
				myself.atInfCenter <- true;
				myself.atFStore <- true;
			}
			
			else if(myself.thirst < 5 and myself.location = inf_loc and (myself.color = #blue or myself.color = #grey)) {
				myself.target_point <- flip(0.5) ? self.dLocation1 : self.dLocation2;
				myself.atInfCenter <- true;
				myself.atDStore <- true;
			}
		}
	}                    
	
	reflex atStore when: (atFStore = true or atDStore = true) {
		if (atFStore = true) {
			do goto target: target_point;
			if (location = target_point) {		
			hunger <- hunger + 1;
			atFStore <- false;	
			target_point <- nil;
			atInfCenter <- false;
			color <- flip(0.5)? #red :#blue;
			
			}
		}
		else if (atDStore = true) {
			do goto target: target_point;
			if (location = target_point) {		
			thirst <- thirst+1;
			atDStore <- false;	
			target_point <- nil;
			atInfCenter <- false;
			color <- flip(0.5)? #red :#blue;
			
			}
			
			}
	}
	
	reflex askWC when: ((hunger = 5 or thirst = 5) and (atInfCenter2 = false)) {
		if(hunger = 5 or thirst = 5 ) {
			write(name + " have to pee");
			target_point <- inf_loc;
			if (atInfCenter3=false) {
				do goto target: target_point;
					if (location=target_point){
						ask info_center{
						if((myself.hunger = 5 or myself.thirst = 5) and myself.location = myself.target_point) {
							myself.target_point <- self.wcLocation;
							myself.atInfCenter2 <- true;
							myself.atInfCenter3<-true;
							write("target: " + myself.target_point);
						}
						
					}
				}
			}
		}
	}
	
	reflex wc when: ((hunger = 5 or thirst = 5) and destination = target_point) {
		if (location != target_point) {
			
			do goto target: target_point;
			hunger <- 0;
			thirst <- 0;
			color <- flip(0.5)? #red :#blue;
			write(target_point);
			atInfCenter2 <- false;
			atInfCenter3 <- false;
			atInfCenter <- false;
			target_point <- nil;
			write(atInfCenter);
		}
	}
	 
		// Go to the specified target point
	reflex move_toTarget when: target_point != nil{
		write(name + " heading to the target: " + target_point);
		do goto target: target_point;
	}
	
	// design
	
 	aspect base
	{
		if(bad) {
		color <- #grey;
		}
		draw sphere(2)  color: color;
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
		draw pyramid(6) color: #green;
	}
	reflex check_if_bad {
		ask guest at_distance 2 {
			if(self.bad) {
				guest badg <- self;
				ask guard {
					if(!(self.badguests contains badg)) {
						self.badguests <- self.badguests + badg;	
					}
				}
				write 'Bad Guest detected! GUARD GUARD GUARD';
			}
		}
	}
}


species guard skills:[moving] {
	
	list<guest> badguests;
	point target_point <- nil;
	
	reflex be_idle when: target_point = nil {
		do wander;	
	}
	
	reflex catchbadguest when: length(badguests) > 0 {
		do goto target:(badguests[0]) speed: 1.5;
	}
	
	reflex killbadguest when: length(badguests) > 0 and location distance_to(badguests[0]) < 0.1 {
		ask badguests[0] {
			write name + ': killed!';
			do die;
		}
	badguests <- badguests - first(badguests);
	}
	

	aspect base {
		draw cube(3)  color: #black;
	}

}


 species fStore {
	
	
	// Design
	aspect base {
		draw cube(5) color: #purple;
	}
	
}


 species dStore {
	aspect base {
		draw cube(5) color: #blue;
	}
}


 species WC {
	aspect base {
		draw cube(4) color: #brown;
	}
}


 experiment main {
 	parameter "Number of guests: " var: num_of_guests; 
	output {
		display map type: opengl {
			species guest aspect: base;
			species info_center aspect: base;
			species fStore aspect: base;
			species dStore aspect: base;
			species WC aspect: base;
			species guard aspect: base;
		}
	}
	
	}
