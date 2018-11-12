/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/
 model basic
 /* Insert your model definition here */
 
 
 /*****************************************  Global declaration **************************************** 
  * contains the number of each agent, the location of inf center and the initialization of the agents
  */
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
		
		create infoCenter number: num_of_inf {
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

/*****************************************  Declaration of the species  **************************************** 
 *  Contains the agents guest, information center, fStore, dStore, wc and guard
 */


/*
 *  The guest agent has hunger and thirst attributes, that start with the value of 0. 
 *  They have a 0.2 probability to be bad. If an agent is bad its color will be grey, if it is hungry it will be red and if thirsty blue.
 *  We introduced a boolean wander1 that is true at first so that all the agents will wander when the simulation is initialized.
 *  As long as their target_point is nil and wander1 is true they will wander in the map.
 *  There is a 0.3 probability that wander1 will be false, and will stop wandering.
 *  A guest will visit the info center if his target point is nil, he is not at the info center currently and wander1 = false.
 *  It will learn the location of the fStore or the dStore depending on its color and the value of hunger/thirst and its target point will change.
 *  Then it will goto the specified store if he is not there and if wander1 = true. Its hunger or thirst is increased by 1 every time it visits 
 *  a store.
 *  When its hunger or thirst has reached 5, it is not at the info center and wander1 = false 
 *  it will visit the information center to learn the loc of the wc. Its target point will change to the loc of the wc.
 *  It will go to the wc if its hunger or thirst is 5, its destination is the wc and wande1 = 5.
 *  When at the wc its hunger and thirst will be reset to 0 and the target point will become nil.
 */
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
	int counter <- 0;
	bool wander1 <- true;
	
	
	reflex be_idle when: (target_point = nil and wander1) {
		write("Wandering");
		do wander;
	}
	
	reflex change_wandering {
		wander1 <- flip(0.3);
	}
	
	reflex hungry_thirsty when: (!wander1) {
		write(name + ":hunger--> " + hunger + ", thirst--> " + thirst);
	}
	
	reflex info_center when: (!wander1) {
		if(target_point = nil) {
			write(name + " heading to the info center.");
		}
	}
	
	
	reflex learn_locs when: (target_point = nil and atInfCenter = false and !wander1) {
		do goto target: inf_loc;
		ask infoCenter {
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
	
	reflex at_store when: ((atFStore = true or atDStore = true) and !wander1) {
		if (atFStore = true) {
			do goto target: target_point;
			if (location = target_point) {		
			hunger <- hunger + 1;
			atFStore <- false;	
			target_point <- nil;
			atInfCenter <- false;
			color <- flip(0.5)? #red :#blue;
			wander1 <- flip(0.5);			
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
			wander1 <- flip(0.5);
			}
		}
	}
	
	reflex ask_WC when: ((hunger = 5 or thirst = 5) and (atInfCenter2 = false) and !wander1) {
		if(hunger = 5 or thirst = 5 ) {
			write(name + " have to visit the wc");
			target_point <- inf_loc;
			if (atInfCenter3=false) {
				do goto target: target_point;
					if (location=target_point){
						ask infoCenter{
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
	
	reflex wc when: ((hunger = 5 or thirst = 5) and destination = target_point and !wander1) {
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
		}
	}
	 
	reflex move_to_target when: (target_point != nil and !wander1) {
		write(name + " heading to the target: " + target_point);
		do goto target: target_point;
	}
	
	
 	aspect base
	{
		if(bad) {
		color <- #grey;
		}
		draw sphere(2)  color: color;
	}
	
}

/*
 *  The info center agent knows the location of the fStores and dStores.
 *  It has only one reflex. It checks every time a guest is at a distance 2 if it is bad.
 *  If the list in the guard species does not contain the bad guest, it will append it to the list.
 */


 species infoCenter {
	
	point fLocation1 <- {10, 10};
	point fLocation2 <- {80, 80};
	
	point dLocation1 <- {80, 10};
	point dLocation2 <- {10, 80};
	
	point wcLocation <- {90, 50};
	
	
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
	
	
	aspect base {
		draw pyramid(6) color: #green;
	}

}

/*
 *  The guard agent has two attributes, a list of type guest and a target point.
 *  When the target point is nil the guard will wander.
 *  When there are elements in the list it will move towards the guest elements in the list.
 *  When the target ( first element in the list) is reached it will kill the guest and remove it from the list.
 */

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
			species infoCenter aspect: base;
			species fStore aspect: base;
			species dStore aspect: base;
			species WC aspect: base;
			species guard aspect: base;
		}
		
		display wandering_chart {
			chart "Number of guests wandering" {
				data "wandering guests" value: length ( guest where(each.wander1));
			}
		}
	}
	
	}
