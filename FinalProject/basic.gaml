/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */

global {
	int num_guests <- 10;
	int num_cops <- 1;
	int num_cleaners <- 1;
	int num_manager <- 1;
	int num_entertainer <- 1;
	int num_stores <- 2;
	int num_wc <- 1;
	int num_stages <- 1;
	int num_rest <- 1;
	int num_cell <- 1;
	
	list<point> store_locs <- [{2,2},{98, 98}];
	
	point info_loc <- {50,50};
	point cell_loc <- {95,5};
	
	init {
		int xStoreLoc <- 2;
		int yStoreLoc <- 2;
		
		create guest number: num_guests;
		
		create infoCenter number: 1 {
			location <- info_loc;
		}
		
		create cleaner number: num_cleaners;
		
		create cop number: num_cops;
	
		create cell number: 1 {
			location <- cell_loc;
		}
		
		create store number:num_stores {
			location <- {xStoreLoc, yStoreLoc};
			xStoreLoc <- 98;
			yStoreLoc <- 98;
		}
	}
}

species guest skills: [moving, fipa] {
	point target_point <- nil;
	
	bool wander <- true;
	bool changed_color <- false;
	bool hungry <- false;
	bool thirsty <- false;
	bool bad <- flip(0.2);
	bool at_info <- false;
	bool remainBad <- false;
	
	int hunger <- 0;
	int thirst <- 0;
	
	rgb color <- #grey;
	
	reflex wandering when:(wander and target_point = nil) {
		do wander;
	}
	
	reflex change_wandering {
		wander <- flip(0.05);
		if !wander and !at_info {
			target_point <- info_loc;
		}
	}
	
	reflex change_color when:(!wander and !changed_color) {
		if (!changed_color and !bad) {
			color <- flip(0.5) ? #red : #blue;
			if color = #red {
				hungry <- true;
			}
			else if color = #blue {
				thirsty <- true;
			}
			changed_color <- true;
		}
		else if(!changed_color and bad) {
			color <- #grey;
			changed_color <- true;
		}
	}
	
	reflex go_to_target when: (!wander and target_point != nil) {
		do goto target:target_point;
	}
	

	aspect base{
 			draw pyramid(3)at:{location.x, location.y, 0} color: color;
 			draw sphere(1) at:{location.x, location.y,3}color: #orange;
	}	
}


species infoCenter skills: [fipa]{
	list<point> store_locs <- [{2,2} , {98, 98}];
	list<guest> bad_guests <- [];
	
	bool cop_informed <- false;
	
	reflex show_locs when: !empty(guest at_distance 1) {
		int pointer <- rnd(1,2);
		ask guest at_distance 2{
			// Pointing the guests to the stores
			if ((self.hungry or self.thirsty) and self.target_point = info_loc) {
				if pointer = 1{
					self.target_point <- store_locs[0];
				}
				else if pointer = 2{
					self.target_point <- store_locs[1];
				}
			}
			self.at_info <- true;
			
			// Informing the cop
			if (self.bad and !myself.cop_informed) {
				add self to: myself.bad_guests;
				do start_conversation(to :: list(cop), protocol :: 'no-protocol', performative :: 'cfp', contents :: ["Bad guests!", myself.bad_guests]);
				myself.cop_informed <- true;
			}
		}
	}
	
	aspect base {
		draw cube(6) at:info_loc color:#darkgreen;
		draw pyramid(6) at:info_loc+{0,0,6} color:#darkgrey;
	}
}

species cop skills: [moving, fipa] {
	
	point target_point <- nil;
	list<guest> bad_guests <- [];
	
	reflex wandering when: target_point = nil {
		do wander;
	}
	
	reflex get_informed when: (!empty(cfps) and target_point = nil) {
		message messageInc <- cfps at 0;
		string alert <- messageInc.contents[0];
		bad_guests <- messageInc.contents[1];
	
		
	}
	
	reflex catchbadguest when: length(bad_guests) > 0 {
		do goto target:(bad_guests[0]) speed: 1.5;
	}
	
	reflex killbadguest when: length(bad_guests) > 0 and location distance_to(bad_guests[0]) < 0.1 {
		ask bad_guests[0] {
			write name + ': go to jail!';
			self.target_point <- cell_loc;
			do goto target: self.target_point;
			self.remainBad <-true;
		}
		bad_guests <- bad_guests - first(bad_guests);
	}

	
	aspect base {
 			draw pyramid(3)at:{location.x, location.y, 0} color: #darkred;
 			draw sphere(1) at:{location.x, location.y,3}color: #black;
	}
}

species cell {
	int jailTime <- 0;
	
	reflex jail  {
		ask guest at_distance 0.1 {
			if self.remainBad =true{
				self.color <- #black;
				myself.jailTime <- myself.jailTime + 1;
				if myself.jailTime = 50 {
					write name + ': i am free';
					self.color <- #grey;
					self.target_point <- nil;
					self.wander <- true;
					self.remainBad <- false;
					myself.jailTime <-0;
					
				}
				
			}
			
		}
	
	}
	
	
	aspect base {
		draw square(10) color: #darkgrey;
	}
}

species cleaner skills: [moving] {
	
	aspect base{
 			draw pyramid(3)at:{location.x, location.y, 0} color: #brown;
 			draw sphere(1) at:{location.x, location.y,3}color: #darkgrey;
 			}
}

species store {
	
	aspect base{
 			draw square(20) color: #darkgrey;
 			draw cube(10) color: #pink;
 		}
}

species entrance {

}

experiment main {
	output {
		display my_display type: opengl {
			species guest aspect:base;
			species infoCenter aspect:base;
			species cop aspect:base;
			species cell aspect:base;
			species cleaner aspect:base;
			species store aspect:base;
		}
		
		
	}
}
