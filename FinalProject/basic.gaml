/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */

global {
	int num_guests <- 5;
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
	
	init {
		int xStoreLoc <- 2;
		int yStoreLoc <- 2;
		
		create guest number: num_guests;
		
		create infoCenter number: 1 {
			location <- info_loc;
		}
		
		create cleaner number: num_cleaners;
		
		create cop number: num_cops;
		
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
	
	int counter <- 500;
	
	rgb color;
	
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
			changed_color <- true;
		}
		if color = #red {
			hungry <- true;
		}
		else if color = #blue {
			thirsty <- true;
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
	
	
	
	reflex show_locs when: !empty(guest at_distance 1) {
		int pointer <- rnd(1,2);
		ask guest at_distance 2{
			if ((self.hungry or self.thirsty) and self.target_point = info_loc) {
				if pointer = 1{
					write "IN pointer 1";
					self.target_point <- store_locs[0];
				}
				else if pointer = 2{
					write "IN pointer 2";
					self.target_point <- store_locs[1];
				}
			}
			self.at_info <- true;
		}
	}
	
	aspect base {
		draw cube(6) at:info_loc color:#darkgreen;
		draw pyramid(6) at:info_loc+{0,0,6} color:#darkgrey;
	}
}

species cop skills: [moving, fipa] {
	
	
	aspect base {
 			draw pyramid(3)at:{location.x, location.y, 0} color: #darkred;
 			draw sphere(1) at:{location.x, location.y,3}color: #black;
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
			species cleaner aspect:base;
			species store aspect:base;
		}
		
		
	}
}
