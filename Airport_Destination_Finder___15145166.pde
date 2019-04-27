
/*
  
  Sam Forde - 15145166

  TITLE:
  Airport Destination Finder

  -------------------------------------------
  PLEASE NOTE: This program uses the ControlP5 Library **
  -------------------------------------------

  BRIEF DESCRIPTION:
  This program allows the user to search and select a world airport.
  The user can progress to the map by pressing 'Spacebar' where they can see all of the destinations
  of this airport. By hovering over a destination they can view the name of the airport. The brighter the destination colour
  means that the airport flies to this airport more than others.

  Copyright (c) 2019 Sam Forde

*/


import controlP5.*;

ControlP5 cp5;

// Create ControlP5 objects
DropdownList d1;
Textfield t1;

// Array Lists
ArrayList<String> destinations = new ArrayList<String>();
ArrayList<String> allRoutes = new ArrayList<String>();
ArrayList<String> allRoutesLongName = new ArrayList<String>();
ArrayList<Float> destinationsLong = new ArrayList<Float>();
ArrayList<Float> destinationsLat = new ArrayList<Float>();
ArrayList<Integer> destinationsValue = new ArrayList<Integer>();
ArrayList<Float> destinationsRadius = new ArrayList<Float>();

String searchAirport, searchAirportLC = "";
String originAirport = "";
String destinationCode;
String focusFullName, focusShortName;
String departureAirport;
String destination;
String destinationOrigin;
String airportCL;
String originName;
String settingsPre;
String sDest;
String route, routeLong;
String routeOption;
String combinedName;
String airportCode;
String airportLongName;
String currentRoute;
String selectedAirport;

int rowsLatLong, rows; // Rows of the data tables
int indexPos, value; //Variables used to checks to see if the destination airport is already in the array
int maxVal, currentVal; // values to find the max value of the destinations
int valueDestination;
int dotColour = #E8E8E8;

float rectLeft, rectRight, rectTop, rectBottom; // positions for the destination rect : hover
float longR, latR;
float hoverWidth;
float centrePointX, centrePointY;
float originalLong, originalLat;
float longitudePoint, latitudePoint;
float longitude, latitude;
float destRadius;
float destColour;
float longitudePos, latitudePos; // Latitude and Logitude value for the destination positions
float originLong, originLat, originX, originY; // Variables to draw the origin airport on the world map
float destinationLat, destinationLong; // Variables used to add the destination Latitude and Longitude to the ArrayLists

PFont Font_basic, Font_hover, pfont;

PImage worldImage, settingsImage, bg; // Variables for the background image

boolean settingsPage = true;
boolean showText = true;
boolean showKey = false;
boolean showDestinations = false;

color WHITE = color(255);
color GREY = color(150);
color BLACK = color(0);

void setup() {
  
  size(1700, 945);
  
  // Title for the Program
  surface.setTitle("15145166 - Airport Destination Finder");
  
  // Fonts
  pfont = createFont("Arial",26,true);
  ControlFont font = new ControlFont(pfont,34);
  Font_basic = createFont("Arial",18);
  Font_hover = createFont("Arial Bold", 22);
  frameRate(48);
  ellipseMode(CENTER);
  rectMode(CENTER);
    
  // background images set as variables
  worldImage = loadImage("worldBig.png");
  settingsImage = loadImage("settingsBackground.png");
  
  // initialize the Settings image when the program starts
  bg = settingsImage;
  
  listArray();
  
  cp5 = new ControlP5(this);

  // create a DropdownList
  d1 = cp5.addDropdownList("List of Airports")
        .setPosition((width/2)-400, 510)
        .setSize(800,400)
        .setFont(font)
        .setOpen(true)
        ;
      
  // create a text field
  t1 = cp5.addTextfield("")
        .setPosition((width/2)-400, 300)
        .setSize(800,100)
        .setFont(font)
        .setFocus(true)
        .setColorCursor(0)
        .setColorBackground(WHITE)
        .setColorActive(BLACK)
        .setColorValue(GREY)
        ;
    
  customize(d1);
}

void customize(DropdownList ddl) {
  // Customize the dropdown list
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(70);
  ddl.setBarHeight(70);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  d1.clear(); // Ensures that the list is empty
}

void draw () {
  // Sets the background image to the image set as 'bg'
  background(bg);
  drawPoints();
  location();
  writeText();
  
  // Show the Key on the World Map page
  if (showKey == true){
    fill(0);
    textFont(Font_hover);
    textSize(25);
    text("Hover over an Airport Destination", 20, 610);
    textFont(Font_basic);
    textSize(19);
    text("Press Spacebar to Return", 20, 360);
    fill(0,0,255);
    stroke(0,0,255);
    ellipse(30,395,15,15);
    fill(0);
    stroke(0);
    rect(30,442,10,10);
    fill(0);
    textSize(20);
    text("Origin Airport", 50, 400);
    text("Destination Airport", 50, 450);
    text("Brighter Destination = More routes", 20, 500);
    text("Darker Destination = Less routes", 20, 550);
  }
  
  if (showDestinations == true){
    for (int r = 0; r < destinationsLong.size(); r++) {
      longR = destinationsLong.get(r);
      latR = destinationsLat.get(r);
      hoverWidth = destinationsRadius.get(r);
      hoverWidth = hoverWidth /2;
      
      // After noticing that the destination points were off on
      // the bottom right corner of the map, this IF statement positions them correctly
      if (longR > 90 && latR < 0){
        rectLeft = (width*(168 + longR)/360) - hoverWidth;
        rectRight = (width*(168 + longR)/360) + hoverWidth;
        rectTop = (height*(91 - latR)/180) + hoverWidth;
        rectBottom = (height*(91 - latR)/180) - hoverWidth;
      } else {
        rectLeft = (width*(170 + longR)/360) - hoverWidth;
        rectRight = (width*(170 + longR)/360) + hoverWidth;     
        rectTop = (height*(85 - latR)/180) + hoverWidth;
        rectBottom = (height*(85 - latR)/180) - hoverWidth;
      }
     
      
      // Checks to see if the mouse is inside an Airport Destination
      if (mouseX >= rectLeft && mouseX <= rectRight && mouseY >= rectBottom && mouseY <= rectTop) {
    
        centrePointX = rectLeft + hoverWidth;
        centrePointY = rectBottom + hoverWidth;
        strokeWeight(2);
        stroke(255,0,0);
        
        // Draws a line from the Origin Airport to the selected Destination Airport
        line (originX, originY, centrePointX, centrePointY);
    
        originalLong = destinationsLong.get(r);
        originalLat = destinationsLat.get(r);
        
        Table tabLatLong = loadTable("latLong.csv");
        rowsLatLong = tabLatLong.getRowCount();
        
        for (int arow = 0; arow < rowsLatLong; arow++) { 
        
          longitudePoint = tabLatLong.getFloat(arow, 6);
          latitudePoint = tabLatLong.getFloat(arow, 5);
          
          // Prints the Airport Destination name to the screen
          if (longitudePoint == originalLong && latitudePoint == originalLat) {
            focusFullName = tabLatLong.getString(arow, 1);
            focusShortName = tabLatLong.getString(arow, 0);
            fill(220);
            stroke(0);
            rect(230,680,430,100);
            fill(0);
            stroke(255,0,0);
            textSize(20);
            textFont(Font_hover);
            text(focusFullName, 20, 660);
            text(originAirport + " - " + focusShortName, 20, 710);
          }
        }      
      }
    }
  } 
}

void location() {
  
  if (showDestinations == true){
    fill(255,0,0);
    strokeWeight(1);
    stroke(0);
    
    //-----------------------
    //DRAW THE ORIGIN AIRPORT
    //-----------------------
    if (originLong > 90 && originLat < 0){
      
      originX = width*(168 + originLong)/360;
      originY = height*(91 - originLat)/180;
    
      fill(0,0,255);
      noStroke();
      ellipse(originX,originY,15,15);
      
    } else {
    
      originX = width*(170 + originLong)/360;
      originY = height*(85 - originLat)/180;
    
      fill(0,0,255);
      noStroke();
      ellipse(originX,originY,15,15);
    }
 
    
    noFill();
    stroke(255, 102, 0);
    showKey = true;
    
  }
}

void data() {
  Table tab = loadTable("routes.csv");
  rows = tab.getRowCount();
  for (int j=0; j<rows; j++) {   
      
    departureAirport = tab.getString(j, 2);
     
    // Checks if the Departure Airport is the Set Origin Airport
    if (departureAirport.equals(originAirport) == true) {
      
      // Gets the destination airport
      destination = tab.getString(j, 4);
          
      if(destinations.size()==0) {
        // If array is empty add it to the array
        destinations.add(destination);
        destinationsValue.add(1);
        maxVal = 1;
                
      } else {
        // Checks to see if the destination airport is already in the Array List
        for (int t=0; t<destinations.size(); t++) {
               
          destinationOrigin = destinations.get(t);
                 
          // If the destination is already in the Array List, then add 1 to its current value
          if (destinationOrigin.equals(destination)==true) {
            indexPos = destinations.indexOf(destinationOrigin);
            value = destinationsValue.get(indexPos);
            value++;
            destinationsValue.set(indexPos, value);
            currentVal = value;
                    
            if (currentVal > maxVal) {
              // Sets the maximum value in the Array List. This is used when mapping the values.
              maxVal = currentVal; 
            }
            break;
          }
        
          // If we've looped through all and destination is not there then just add to list
          if(t==destinations.size() -1) {
            
            destinations.add(destination);
            destinationsValue.add(1);
          }             
        }
      }                 
    }    
  }
    
  
    
  Table tabLatLong = loadTable("latLong.csv");
  rowsLatLong = tabLatLong.getRowCount();
    
  // Get the latitude and longitude position of the origin airport
  for (int arow = 0; arow < rowsLatLong; arow++) { 
    originName = tabLatLong.getString(arow, 0);
      
    if (originName.equals(originAirport) == true){
      originLong = tabLatLong.getFloat(arow, 6);
      originLat = tabLatLong.getFloat(arow, 5);
    }
  }
  
  // Get the latitude and longitude positions of the destination airports of the selected origin airport
  for(int t=0; t<=destinations.size()-1; t++) {
    for (int a=0; a<rowsLatLong; a++) { 
      sDest = tabLatLong.getString(a, 0);
     
      if (sDest.equals(destinations.get(t)) == true) {
        destinationLat = tabLatLong.getFloat(a, 5);
        destinationLong = tabLatLong.getFloat(a, 6);
        destinationsLat.add(destinationLat);
        destinationsLong.add(destinationLong);
        
        break;
      }
    }
  }
}
  
//  Function to draw the Destinations
void drawPoints() {
  if (showDestinations == true) { // If the boolean variable 'showDestinations' is true, enter the statement
    for (int s = 0; s < destinationsLong.size(); s++){
      longitude = destinationsLong.get(s);
      latitude = destinationsLat.get(s);
      valueDestination = destinationsValue.get(s);
      noStroke();
      
      // Uses the number of airlines that fly to the airport to retrieve Radius and Colour values
      destRadius = map(valueDestination, 1, maxVal, 4, 7); // Radius of the destination
      destColour = map(valueDestination, 1, maxVal, 0, 255); // Colour of the destination
      destinationsRadius.add(destRadius);
      
      // Algorithm to get the positions of the destinations on the map using the Latitude and Longitude positions
      if (longitude > 90 && latitude < 0) {
        longitudePos = width*(168 + longitude)/360;
        latitudePos = height*(91 - latitude)/180;
        
        // Drawing the destination rectangle
        fill(destColour,0,0);
        rect(longitudePos,latitudePos,destRadius,destRadius);
      } else {
        longitudePos = width*(170 + longitude)/360;
        latitudePos = height*(85 - latitude)/180;
        fill(destColour,0,0);
        rect(longitudePos,latitudePos,destRadius,destRadius);
      }
    }
    stroke(0);
  }
}

void keyPressed() {
    
  if (key == 32) { // 32 = the keyCode for Spacebar 
    if (settingsPage == true) { // If the settings page is active, enter this loop
        
      // Get the airport selected from the dropdown menu
      selectedAirport = cp5.getController("List of Airports").getLabel();
        
      // Get first 3 characters of the string (these are the airports short code)
      char char1 = selectedAirport.charAt(0);
      char char2 = selectedAirport.charAt(1);
      char char3 = selectedAirport.charAt(2);
        
      // Setting the origin airport as the fist 3 characters
      originAirport = char1 + "" + char2 + "" + char3;
      
      settingsPage = false;
      dotColour = 0;
      bg = worldImage; // Set background image to the World Map image
      showDestinations = true;
      
      // Don't show the GUI objects
      d1.setVisible(false);
      t1.setVisible(false);
      
      showText = false;
      
      data();
    } else if (settingsPage == false) { // If the settings page is NOT active, enter this loop
      
      for(int i = destinations.size()-1; i >= 0; i--) {
        // Loop to remove all the data from the ArrayLists
        destinations.remove(i);
        destinationsValue.remove(i);
        destinationsRadius.remove(i);
      }
      for(int i = destinationsLong.size()-1; i >= 0; i--) {
        // Loop to remove all the data from the ArrayLists
        destinationsLong.remove(i);
        destinationsLat.remove(i);
      }
      
      settingsPage = true;
      dotColour = #E8E8E8;
      bg = settingsImage;
      t1.clear();
      d1.clear();
      d1.setLabel("List of Airports");
      showText = true;
      showKey = false;
      showDestinations = false;
      
      // Show the GUI objects
      d1.setVisible(true);
      t1.setVisible(true);
    }
  }
}

// Using keyReleased to update the Dropdown List on the Settings Page
void keyReleased() {
  
  searchAirport = t1.getText(); // Gets the text from the text field
  searchAirport = searchAirport.toUpperCase(); // Puts the text to Upper Case
  searchAirportLC = searchAirport.toLowerCase(); // Puts the text to Lower Case
    
  if (searchAirport.equals("")==true) {
  } else {
    // Puts the text to Sentence Case (Capital letter first)
    airportCL = searchAirport.substring(0,1).toUpperCase() + searchAirport.substring(1).toLowerCase();
  }
    
  d1.clear(); // Clears the dropdown list to ensure it's empty
    
  for (int i=0;i<allRoutesLongName.size();i++) {
    route = allRoutes.get(i); // Short airport code - E.G. 'DUB'
    routeLong = allRoutesLongName.get(i); // Long airport name - E.G. 'Dublin Airport'
    
    // Combining the short code and long name -> DUB - Dublin Airport
    combinedName = route + " - " + routeLong; 
    
    if (searchAirport.equals("")==true) {
      // Clears the dropdown if the text field is empty
      d1.clear();
    }
    else if (combinedName.contains(searchAirport)) {
      // If an airport contains the searched text (Captial Letters)
      d1.setOpen(true); // Opens the Dropdown List
      d1.addItem(combinedName, i); // Adds the airport to the Dropdown List
    } else if (combinedName.contains(airportCL)) {
      // If an airport contains the searched text (First letter is a capital letter)
      d1.setOpen(true);
      d1.addItem(combinedName, i);
    } else if (combinedName.contains(searchAirportLC)) {
      // If an airport contains the searched text (Lowercase letters)
      d1.setOpen(true);
      d1.addItem(combinedName, i);
    }
  }
}

// Function to put every airport in the CSV file into an ArrayList
void listArray () {
  Table tab = loadTable("routes.csv");
  int rows = tab.getRowCount();
    
   for (int j=0; j<rows; j++) {   
      routeOption = tab.getString(j, 2);
      
       if(allRoutes.size()==0) {
             //if array is empty add it to the array
              allRoutes.add(routeOption);
         }
         else {
            for (int t=0; t<allRoutes.size(); t++) {
               String val = allRoutes.get(t);
                // if the route is already in the arrayList, then 'break'
                if (val.equals(routeOption)==true) {
                 break;
                } 
                // if gone through all of the arrayList and destination is not there then just add to the list
                if(t==allRoutes.size() -1) {
                  allRoutes.add(routeOption);
                  
                }
            }
          } 
   }
   
    getLongNames(); // Get the long names of all of the routes
}

// Function to get the Full Name of each airport
void getLongNames () {
  
  Table tab2 = loadTable("latLong.csv");
  int rows2 = tab2.getRowCount();
    
  for (int i = 0; i<allRoutes.size();i++){
    currentRoute = allRoutes.get(i);
    for (int j=0; j<rows2; j++) { 
        
      airportCode = tab2.getString(j, 0);
      
      if (currentRoute.equals(airportCode) == true) {
        airportLongName = tab2.getString(j, 1);
        allRoutesLongName.add(airportLongName); // Adds long name to the Array List
        break;
      } else if(j==rows2 -1) {
        allRoutesLongName.add(" ");
      } else {
      }
    }
  }
}

// Writes the text on the Settings Page
void writeText() {
  if (showText == true) {
    fill(0);
    textSize(50);
    text("Airport Destination Finder", 540, 50);
    
    textSize(30);
    text("Search for an Airport below in the Text Field", 520, 240);
    textSize(20);
    text("e.g. DUB, Dubai, JFK, Shannon", 690, 270); 
    
    textSize(30);
    text("Select an airport from the list below", 580, 450); 
    text("and press Spacebar to continue", 610, 490); 
  }
}
