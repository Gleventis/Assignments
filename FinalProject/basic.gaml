/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/* Insert your model definition here */

global {
	int num_guests <- 50;
	int num_cops <- 1;
	int num_cleaners <- 10;
	int num_manager <- 1;
	int num_entertainer <- 1;
	int num_stores <- 2;
	int num_wc <- 1;
	int num_stages <- 3;
	int num_rest <- 1;
	int num_cell <- 1;
	int num_rd_bar <- 1;
	int num_pd_bar <- 1;
	
	list<point> store_locs <- [{2,2},{98, 98}];
	
	point wc_loc <- {10, 50};
	
	point info_loc <- {50,50};
	
	point cell_loc <- {95,5,0.1};
	
	point rest_place_loc <- {5,95};
	
	point rd_bar_loc <- {47, 4};
	
	point pd_bar_loc <- {47, 96};
	
	init {
		int xStoreLoc <- 2;
		int yStoreLoc <- 2;
		
		create guest number: num_guests;
		
		create rd_bar number: num_rd_bar {
			location <- rd_bar_loc;
		}
		
		create pd_bar number: num_pd_bar {
			location <- pd_bar_loc;
		}
		
		create stageManager number: 1;
		
		create entertainer number: num_entertainer;
		
		create stages number:num_stages{
		
		}
		
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
		
		create wc number: num_wc {
			location <- wc_loc;
		}
		
		create rest_place number: 1 {
			location <- rest_place_loc;
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
	bool cop_informed <- false;
	bool ready_for_wc <- false;
	bool need_to_rest <- false;
	bool dirty <- false;
	bool informed<-false;
	bool calculated<-false;
	bool updated <-false;
	bool going_to_stage <- false;
	bool communicate <- true;
	bool has_communicated <- false;
	bool has_music <- false;
	bool conflict <- false;
	
	int hunger <- 0;
	int thirst <- 0;
	int stamina <- 400;
	int w_counter <- 0;
	int pos<-0;
	int speech <- rnd(1,10);
	int happiness <- 0;
	
	float music <- (rnd(0.0,1));
 	float soundQuality <- (rnd(0.0,1));
	float band <- (rnd(0.0,1));
	float crowded<- (rnd(0.0,1));
	float utility1;
	float utility2;
	float utility3;
	float max;

		
	list<float> stageAtt <- ([]); 
	list<float> myutility <- ([]);
	list ActiveStages;
	list<string> music_types <- ["rock", "pop", "disco"];
	
	string music_taste <- "";
		
	rgb color <- #teal;
	
	reflex choose_music when: !has_music {
		int random <- rnd(1,3);
		if random = 1 {
			music_taste <- music_types[0];
		}
		else if random = 2 {
			music_taste <- music_types[1];
		}
		else if random = 3 {
			music_taste <- music_types[2];
		}
		write name + "-->" + music_taste;
		has_music <- true;
	}
		
	reflex wandering when:(wander and target_point = nil and w_counter < 30) {
		if w_counter < 30 {
			do wander;
			w_counter <- w_counter + 1;
		}
	}
	
	reflex change_wandering when: w_counter = 30{
		wander <- false;
		if !wander and !at_info {
			target_point <- info_loc;
		}
	}
	
	reflex getting_tired when: (stamina > 50 and !need_to_rest){
		communicate <- flip(0.1);
		stamina <- stamina - 1;
	}

	reflex change_color when:(!wander and !changed_color) {
		if (!changed_color and !bad) {
			color <- flip(0.5) ? #red : #blue;
			if color = #red or #grey{
				hungry <- true;
			}
			else if color = #blue or #grey{
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
	
	reflex interested when: !empty(informs) {
		message messageInc <- informs at 0;
		stageAtt <- messageInc.contents[1];
		informed <- true;
	}
	
	reflex calculate_stage_utility when: informed {
		utility1<-  ((stageAtt[0] * music) + (stageAtt[1] * soundQuality)  + (stageAtt[2] * band) + (stageAtt[3] * crowded));
		utility2<-  ((stageAtt[4] * music) + (stageAtt[5] * soundQuality)  + (stageAtt[6] * band) + (stageAtt[7] * crowded));
		utility3<-  ((stageAtt[8] * music) + (stageAtt[9] * soundQuality)  + (stageAtt[10] * band) + (stageAtt[11] * crowded));
		write name + utility1;
		write name + utility2;
		write name + utility3;
		add utility1 to: myutility;
		add utility2 to: myutility;
		add utility3 to: myutility;
		informed<-false;
		
		if length(myutility)=3 {

			max <- max(myutility);
			write  name + " max value: " + max;
			loop i from: 0 to: length(myutility)-1 {
				if  max = float(myutility[i]){
					write name+ " pos " + i;
					pos <- i;
				}
			}		
		}
		calculated <- true;
		wander <- false;
		updated<-false;
	}
	
	reflex gotostage  when:(calculated){
		ask stages{
			add self to: myself.ActiveStages;
		}
		loop g over: guest {
			if pos=0{
				target_point<-ActiveStages[0];
			}
			else if pos=1{
				target_point<-ActiveStages[1];
			}	
			else if pos=2{
				target_point<-ActiveStages[2];
			}

			
		}
		calculated <- false;
		stageAtt<-[];
				myutility<-[];
		
	 }
	
	reflex spawn_garbage when:(thirst = 5 or hunger = 5) and dirty {
		create garbage number: 1 {
			location <- self.location;
		}
	}
	
	reflex resetAtt when: !updated{

		ask stages{
			if time >=1{ 
				myself.myutility<-[];
		 		self.newstageAtt<-[];


		 		myself.updated<-true;
		 		
		 		}
		 	
		}	
		
	 }
	// Interaction
	reflex interact when: !going_to_stage {
		ask guest at_distance 0.5 {
			if myself.communicate and self.communicate {
				//write myself.name + " is communicating with " + self.name;
				if myself.music_taste = "rock" and self.music_taste = "rock" {
					//write myself.name + " has no conflict with " + self.name;
					self.target_point <- rd_bar_loc;
					myself.target_point <- rd_bar_loc;
					self.wander <- false;
					myself.wander <- false;
					myself.has_communicated <- true;
					self.has_communicated <- true;
					myself.conflict <- false;
					self.conflict <- false;
				}
				else if myself.music_taste = "pop" and self.music_taste = "pop" {
					//write myself.name + " has no conflict with " + self.name;
					self.target_point <- pd_bar_loc;
					myself.target_point <- pd_bar_loc;
					self.wander <- false;
					myself.wander <- false;
					myself.has_communicated <- true;
					self.has_communicated <- true;
					myself.conflict <- false;
					self.conflict <- false;
				}
				else if myself.music_taste = "disco" and self.music_taste = "disco" {
					//write myself.name + " has no conflict with " + self.name;
					self.target_point <- pd_bar_loc;
					myself.target_point <- pd_bar_loc;
					self.wander <- false;
					myself.wander <- false;
					myself.has_communicated <- true;
					self.has_communicated <- true;
					myself.conflict <- false;
					self.conflict <- false;
				}
				else if myself.music_taste = "rock" and self.music_taste = "disco" {
					//write myself.name + " has no conflict with " + self.name;
					self.target_point <- rd_bar_loc;
					myself.target_point <- rd_bar_loc;
					self.wander <- false;
					myself.wander <- false;
					myself.has_communicated <- true;
					self.has_communicated <- true;
					myself.conflict <- false;
					self.conflict <- false;
				}
				else if myself.music_taste = "pop" and self.music_taste = "disco" {
					//write myself.name + " has no conflict with " + self.name;
					self.target_point <- pd_bar_loc;
					myself.target_point <- pd_bar_loc;
					self.wander <- false;
					myself.wander <- false;
					myself.has_communicated <- true;
					self.has_communicated <- true;
					myself.conflict <- false;
					self.conflict <- false;
				}
				else if myself.music_taste = "rock" and self.music_taste = "pop" {
					write myself.name + " conflict with " + self.name;
					myself.conflict <- true;
					self.conflict <- true;
				}
				
				if (myself.conflict or self.conflict) {
					if myself.speech > self.speech {
						write "I am " + self.name + " and " + myself.name + " has persuaded me to change music.";
						self.music_taste <- myself.music_taste;
						write self.name + " -->" + self.music_taste;		
					}
					else if myself.speech < self.speech {
						write "I am " + myself.name + " and " + self.name + " has persuaded me to change music.";
						myself.music_taste <- self.music_taste;
						write myself.name + " -->" + myself.music_taste;
					}
					else if myself.speech = self.speech {
						myself.bad <- flip(0.3);
						if myself.bad {
							write myself.name + " I am bad!";
						}
						self.bad <- flip(0.3);
						if self.bad {
							write self.name + " I am bad!";
						}
					}
				}	
			
			}
				
				
		}
		
	}	

	aspect base{
 			draw pyramid(3)at:{location.x, location.y, 0} color: color;
 			draw sphere(1) at:{location.x, location.y,3} color: #orange;
	}	
}

species rd_bar {
	
	reflex increase_happiness {
		ask guest at_distance 0 {
			if (self.music_taste = "rock" or self.music_taste = "disco") and self.has_communicated{
				self.happiness <- self.happiness + 1;
				write self.name + " is listening to rock/disco and is having fun!";
				self.communicate <- false;
				self.has_communicated <- false;
				self.wander <- true;
				self.target_point <- nil;
				self.w_counter <- 0;
				self.at_info <- false;
			}
		}
	} 
	
	aspect base {
		draw cube(6) color: #lightgrey;
	}
}

species pd_bar {
	reflex increase_happiness {
		ask guest at_distance 0 {
			if (self.music_taste = "pop" or self.music_taste = "disco") and self.has_communicated {
				self.happiness <- self.happiness + 1;
				write self.name + " is listening to pop/disco and is having fun!";
				self.communicate <- false;
				self.has_communicated <- false;
				self.wander <- true;
				self.target_point <- nil;
				self.w_counter <- 0;
				self.at_info <- false;
			}
		}
	}
	
	aspect base {
		draw cube(6) color: #lightgrey;
	}
}


species infoCenter skills: [fipa]{
	list<point> store_locs <- [{2,2} , {98, 98}];
	list<guest> bad_guests <- [];
	
	
	
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
			// Pointing the guests to the wc
			if self.ready_for_wc {
				self.target_point <- wc_loc;
			}
			
			if self.stamina = 50 {
				self.target_point <- rest_place_loc;
				self.need_to_rest <- true;
			}
			
			self.at_info <- true;
			
			// Informing the cop
			if (self.bad and !self.cop_informed and self.color = #grey) {
				add self to: myself.bad_guests;
				do start_conversation(to :: list(cop), protocol :: 'no-protocol', performative :: 'cfp', contents :: [self.name + " is a bad guest!", myself.bad_guests]);
				self.cop_informed <- true;
			}
		}
	}
	
	aspect base {
		draw cube(6) at:info_loc color:#darkgreen;
		draw pyramid(6) at:info_loc+{0,0,6} color:#darkgrey;
	}
}

species garbage {
	
	aspect base {
		draw square(1) color:#black;
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
		ask guest at_distance 1 {
			if self.remainBad =true{
				self.color <- #black;
				myself.jailTime <- myself.jailTime + 1;
				if myself.jailTime = 50 {
					write name + ': i am free';
					self.color <- flip(0.2) ? #grey : #teal;
					if self.color = #grey {
						self.bad <- true;
						self.cop_informed <- false;
					}
					else if (self.color = #teal) {
						self.bad <- false;
					}
					self.target_point <- nil;
					self.wander <- true;
					self.remainBad <- false;
					self.at_info <- false;
					self.changed_color <- false;
					self.w_counter <- -10;
					myself.jailTime <-0;
					
				}
				
			}
			
		}
	
	}
	
	
	aspect base {
		draw square(10) color: #black;
	}
}


species stageManager skills: [moving, fipa] {
	list<float> stageAtt <- ([]); 
	bool informed <- false;
	bool wander <-true;
	bool atInfoCenter <-false;
	bool has_informed <- false;
	
	reflex learnAtt when: !informed and ((time mod 500) = 0){
		ask stages {
			if self.newstageAtt=[]{
					self.music <- (rnd(0.0,1));
					self.soundQuality <- (rnd(0.0,1));
					self.band <- (rnd(0.0,1));
					self.crowded <- (rnd(0.0,1));
					add self.music to: self.newstageAtt;
					add self.soundQuality to: self.newstageAtt;
					add self.band to: self.newstageAtt;
					add self.crowded to: self.newstageAtt;
					write " Stage: " + self.name + " updated its Attributes: " + self.newstageAtt;
				

			 
			 }
			 add self.newstageAtt[0] to: myself.stageAtt;
		  	 add self.newstageAtt[1] to: myself.stageAtt;
		   	 add self.newstageAtt[2] to: myself.stageAtt;
		   	 add self.newstageAtt[3] to: myself.stageAtt;
			 myself.informed <- true;
		}
		
	}
	
	reflex wander when:wander{
		do wander;	
	}
	
	
	reflex informShow when: !atInfoCenter{
		if time >=400 {
			do goto target:info_loc;
			wander <- false;
		}
		if location distance_to(info_loc) < 2 and !has_informed and ((time mod 500) = 0){
			atInfoCenter <-false;
			write name + " arrived at info center, shows are coming !";
			do start_conversation(to :: list(guest), protocol :: 'no-protocol', performative :: 'inform', contents :: [name + " Show is about to start!", stageAtt]);
			do start_conversation(to :: list(stages), protocol :: 'no-protocol', performative :: 'inform', contents :: [name + " Show is about to start!"]);
			

		}
			wander <-true;
			informed <-false;
			stageAtt<-[];
	}
	
	aspect base{
 			draw pyramid(3)at:{location.x, location.y, 0} color: #grey;
 			draw sphere(1) at:{location.x, location.y,3} color: #fuchsia;
	}
	
}

species stages  skills: [fipa] {
	float music <- (rnd(0.0,1));
 	float soundQuality <- (rnd(0.0,1));
	float band <- (rnd(0.0,1));
	float crowded<- (rnd(0.0,1));
	bool print <- false;
	bool party <- false;
	list<float> newstageAtt <- ([music,soundQuality,band,crowded ]); 
	rgb color <- #magenta;
	int counter <- 0;
	bool updated <- false;
	bool informed <- true;
	
	reflex print  when:  !print   {
		write "name: "+ name + " music: " + music + " sound Quality: " + soundQuality +  " band: " + band +   " crowded: "  +  crowded;
		print<-true;
	}
	

	
	reflex change_party when: time !=0 and (time mod 500)=0{
		party <- true;
		
	}
	
	reflex showtime when: party {
		
		if (flip(0.5)) {
			color<- #red;		
		} 
		else {
			color<- #blue;
		}
		counter<-counter+1;
		if counter>200 {
			party <- false;
			color <- #magenta;
			counter <-0;
			ask guest at_distance 2 {
				self.w_counter <- 0;
				self.wander <- true;
				self.at_info <- false;
				self.target_point <- nil;
				self.going_to_stage <- false;
				
			}
		}
		
	}
	
	aspect base {
 		draw square(10) at:{location.x, location.y,0}color: color;
		}
	
}

species entertainer skills: [moving, fipa] {
	bool wander <- true;
	
	list<point> stage_loc <- [];
	
	reflex wandering when:wander {
		do wander;
	}
	
	reflex go_to_stages when:(!empty(informs)) {
		message messageInc <- informs at 0;
		ask stages {
			if !(myself.stage_loc contains self.location) {
				add self.location to:myself.stage_loc;
				write myself.stage_loc;
			}
		}
	}
	
	aspect base {
		draw pyramid(3) at:{location.x, location.y} color: #green;
		draw sphere(1) at:{location.x,location.y, 3} color: #red;
	}
	
}

species cleaner skills: [moving] {
	
	point target_point <- nil;
	int range <- 5;
	
	reflex wandering when: target_point = nil{
		do wander speed: 3.0;
		if !empty(garbage at_distance 4) {
			ask garbage at_distance 4 {
				do die;
			}
		}
	}
	
	aspect base{
 			draw pyramid(3)at:{location.x, location.y, 0} color: #brown;
 			draw sphere(1) at:{location.x, location.y,3}color: #darkgrey;
 			}
}

species store {
	
	reflex give_food_drink when:(!empty(guest at_distance 1)) {
		ask guest at_distance 1{
			if self.color = #red and self.hunger < 5{
				self.hunger <- self.hunger + 1;
				self.target_point <- nil;
				self.at_info <- false;
				self.changed_color <- false;
				self.dirty <- flip(0.1);
				self.w_counter <- -5;
				self.wander <- true;
				if(self.hunger = 5) {
					self.hungry <- false;
				}
			}
			else if self.color = #blue and self.thirst < 5 {
				self.thirst <- self.thirst + 1;
				self.target_point <- nil;
				self.at_info <- false;
				self.changed_color <- false;
				self.dirty <- flip(0.1);
				self.w_counter <- -5;
				self.wander <- true;
				if(self.thirst = 5) {
					self.thirsty <- false;
				}
			}
			if(self.hunger = 5 or self.thirst = 5) {
				ready_for_wc <- true;
				self.target_point <- nil;
			}
		}
	}
	
	aspect base{
 			draw square(20) color: #darkgrey;
 			draw cube(10) color: #pink;
 		}
}


species wc {
	
	reflex reset_hunger_thirst when:(!empty(guest at_distance 1)) {
		ask guest at_distance 1 {
			self.hunger <- 0;
			self.thirst <- 0;
			self.ready_for_wc <- false;
			self.target_point <- nil;
			self.at_info <- false;
			self.w_counter <- -5;
			self.wander <- true;
			self.changed_color <- false;
		}
	}
	
	
	aspect base {
		draw cube(6) color: #brown;
	}
}


species rest_place {
	int counter <- 0;
	
	reflex replenish_stamina when:(!empty(guest at_distance 1)) {
		ask guest at_distance 1 {
			if myself.counter < 100 and self.need_to_rest {
				self.stamina <- self.stamina + 50;
				myself.counter <- myself.counter + 1;
				if myself.counter = 100 {
					self.need_to_rest <- false;
					self.target_point <- nil;
					self.at_info <- false;
					self.wander <- true;
					self.bad <- flip(0.2);
					self.changed_color <- false;
					self.w_counter <- -5;
					myself.counter <- 0;
				}
			}
		}
	}
	
	aspect base {
		draw square(10) color: #black;
	}
}

species entrance {

}

experiment main {
	output {
		display my_display type: opengl {
			image file: "grass.jpg";
			species guest aspect:base;
			species infoCenter aspect:base;
			species cop aspect:base;
			species cell aspect:base;
			species cleaner aspect:base;
			species garbage aspect:base;
			species store aspect:base;
			species wc aspect:base;
			species stages aspect:base;
			species rest_place aspect:base;
			species stageManager aspect:base;
			species entertainer aspect: base;
			species rd_bar aspect: base;
			species pd_bar aspect: base;
		}
		
		
	}
}
