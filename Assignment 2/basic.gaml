/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/*
 *  ******************** GLOBAL STARTS HERE ***********************
 */
global {
	point exit_loc <- {50, 0};
	point guest_loc <- {15, 90, -10};
	int guest_num <- 5;
	int balance <- 5000;
	int minCost <- 100;
	int maxCost <- 1000;
	
	init{
		
		create guest number: guest_num; 
		
		create exit number: 2 {
			location <- exit_loc;
		}
		
		create auctioneer number: 1 {
			location <- exit_loc;
		}
		
		create scene number: 1 {
			location <- guest_loc;
		}
	}
	
}
/*
 *  ******************** GLOBAL ENDS HERE ****************************
 */

/*
 *  ******************** SPECIES START HERE *************************
 */

species guest skills:[moving, fipa] {
	point target_point <- nil;
	int preferredPrice <- rnd(minCost, maxCost);
	int counter <- 100;

	
	reflex do_wander when: (counter > 0) {
		do wander;
		counter <- counter - 1;
	}
	
	reflex go_to_scene when: (counter = 0) {
		do goto target: guest_loc;
	}
	
	reflex reply_message when: (!empty(requests)) {
		message requestFromAuctioneer <- (requests at 0);
		if(preferredPrice > 500) {
		do agree with: (message: requestFromAuctioneer, contents:[name + ' I will']);
		}
		else {
			do failure with: (message: requestFromAuctioneer, contents: [name + ' I reject, sorry not sorry']);
		}
	}
	
	aspect base {
		draw pyramid(3) color: #blue ;
	}
}


species auctioneer skills:[fipa, moving]{

	list<guest> gue;
	
	reflex auction_starting when: (time = 99) {
		write "Auction starts in 10 minutes";
	}
	
	reflex go_to_scene when:(time >= 109) {
		do goto target: guest_loc + {18, -18};
	}
	
//	reflex send_request when: (time = 1) {
//		guest g <- guest at 0;
//		write(name + " sends message");
//		do start_conversation (to :: [g], protocol :: 'fipa-request', performative :: 'request', contents :: ['go sleeping'] );
//	}
//	
//	reflex read_agree_message when: !(empty(agrees)) {
//		loop a over: agrees {
//			write(" agrees message with content: " + string(a.contents));
//		}
//	}
//	
//	reflex read_failure_message when: !(empty(failures)) {
//		loop f over: failures {
//			write(" rejects message with content: " + (string(f.contents)));
//		}
//	}
	
	aspect base {
		draw pyramid(3) color: #660624;
	}
}

species exit {
	
	rgb color <- #green;
	
	aspect base {
		draw circle(6) color: color;
	}
	
}

species scene {
	aspect base {
		draw square(18) color: #darkred;
	}
}

/*
 *  *************************** SPECIES END HERE **************************
 */

experiment main {
	
	output {
		
		display map type: opengl {
			species guest aspect: base;
			species auctioneer aspect: base;
			species exit aspect: base;
			species scene aspect: base;
		}
	}
}
