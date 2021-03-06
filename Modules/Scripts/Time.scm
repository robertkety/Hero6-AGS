AGSScriptModule      Time 1.0 �  // Main script for module 'Time'

#define MAX_RAINDROPS 50

#define SUNSET_START 4275
#define SUNSET_FINISH 4500

#define SUNRISE_START 1125
#define SUNRISE_FINISH 1350

#define END_DAY 5400


bool enableDayNightColourHandling = true;
export enableDayNightColourHandling;

short darknessOffset = 0;
export darknessOffset;

int darkness = 100;

bool isRaining;
short rainVisibility;
bool isRainStopping;

struct Raindrop {
  int x, y, z; 
  bool visible;
};

Raindrop raindrops[MAX_RAINDROPS];

DrawingSurface *buffer;

function HandleRain() {
  int a = GetRoomProperty("Scene Flag");
  if (!isRaining || a == 5 || a == 7) return;
  
  DrawingSurface *surface = Room.GetDrawingSurfaceForBackground();
  if (buffer == null) buffer = surface.CreateCopy();
    
  surface.DrawSurface(buffer);
  
  int i = 0;
  while (i < MAX_RAINDROPS) {

    if (raindrops[i] != null && !raindrops[i].visible) {
      int xxx, yyy;
      while (GetWalkableAreaAt(xxx, yyy) == 0) {
        xxx = Random(320);
        yyy = Room.TopEdge + Random(235 - Room.TopEdge);
      }
      raindrops[i].x = xxx;
      raindrops[i].y = yyy;
      
      raindrops[i].z = raindrops[i].y + 20;
      raindrops[i].visible = true;
      
    }
    if (raindrops[i].z <= 1) {
      raindrops[i].visible = false;
      surface.DrawImage(raindrops[i].x, raindrops[i].y - raindrops[i].z, 2279,  minInt(98 - (rainVisibility * 2), 99));
    }
    else {
      surface.DrawImage(raindrops[i].x, raindrops[i].y - raindrops[i].z, 2278,  minInt(98 - (rainVisibility * 2), 99));
      raindrops[i].z -= 10;
    }
    i++;
  }
  cRainCloud.Transparency = minInt(98 - (rainVisibility * 2), 99);
  surface.Release();
}
function endRain() {
  //Display("Rain ending");
  //rainVisibility = -1;
  isRainStopping = true;
}
function startRain() {
  if (flags.Chapter == 0) return;
  if (isRaining) {
    endRain();
    return;
  }
  //Display("Rain starting");
  isRaining = true;
  rainVisibility = 1;
  SetTimer(13, 2);
}
bool isday() {
  //if (timeinfo.TimeState > 0) and (timeinfo.TimeState < 7) then
  if (timeinfo.ticks > SUNRISE_FINISH && timeinfo.ticks < SUNSET_START)
    return true;
  else return false;
  
}
function flushDrawStarsBuffer() {
  if (buffer == null) return;
  buffer.Release();
  buffer = null;
}
function SetDarkness(int dark) {
  cFilter.ChangeRoom(cEgo.Room);
  cFilter.Transparency = dark;
  
  //SetFlashlightDarkness(dark);
}
function SetTint(int red, int green, int blue) {
  cFilterRED.ChangeRoom(cEgo.Room);
  cFilterGREEN.ChangeRoom(cEgo.Room);
  cFilterBLUE.ChangeRoom(cEgo.Room);
  
  
  cFilterRED.Transparency = 99-red;
  cFilterGREEN.Transparency = 99-green;
  cFilterBLUE.Transparency = 99-blue;
  //Display("%d", cFilterBLUE.Transparency);
  //SetFlashlightTint(red, green, blue);
  //cFilter.Tint(red, green, blue, 100, 100);
  //cFilter.Tint(red, green, blue,  100, 100);
  //if (buffer == null) return;
  //DrawingSurface *surface = buffer.CreateCopy();
  //surface.DrawImage(0, 0, 2282, 100-red);
  //surface.DrawImage(0, 0, 2283, 100-green);

  //surface.DrawImage(0, 0, 2284, 100-blue);
  //surface.Release();
}
function SetTint2(int red, int green, int blue, int sat, int lum) {
  //SetFlashlightTint(red, green, blue);
  //cFilter.Tint(red, green, blue, 100, 100);
  //cFilter.Tint(red, green, blue, sat, lum);
}
function drawStars(int trans) {
  String data = Room.GetTextProperty("Stars");
  int i = 0; 
  int j = 0;
  String num = "";
  
  DrawingSurface *surface = Room.GetDrawingSurfaceForBackground();
  if (buffer == null) buffer = surface.CreateCopy();
  
  
  surface.DrawSurface(buffer);
  while (i < data.Length) {
    num = "";
    char c = data.Chars[i];
    while (c != ',') {
      num = num.AppendChar(data.Chars[i]);
		  i++;
      c = data.Chars[i];
    }
    int x = num.AsInt;
    i++;
    c = data.Chars[i];
    num = "";
    while (c != ';') {
      num = num.AppendChar(data.Chars[i]);
		  i++;
      c = data.Chars[i];
    }
    int y = num.AsInt;
    surface.DrawImage(x, y, 947, 100 - minInt(99, trans));
    i++;
  }
  surface.Release();
}
function ProcessDayAndNight() {
 //////////day and night system///////////////
    
    int red = 0, green = 0, blue = 0, dark = 0, stars = 99;
	  // if not interior
		if (GetRoomProperty("Scene Flag") != 5 && GetRoomProperty("Scene Flag") != 7) {
			if (timeinfo.ticks > SUNSET_START && timeinfo.ticks < SUNSET_FINISH) {
			  float dist = IntToFloat(timeinfo.ticks - SUNSET_START);
			  
			  dark = 100 - FloatToInt((dist / IntToFloat(SUNSET_FINISH - SUNSET_START)) * 50.0);
				red = FloatToInt((dist / IntToFloat(SUNSET_FINISH - SUNSET_START)) * (-4.0));
			  blue = FloatToInt((dist / IntToFloat(SUNSET_FINISH - SUNSET_START)) * 8.0);
				
				stars = FloatToInt((dist / IntToFloat(SUNSET_FINISH - SUNSET_START)) * 99.0);
			}
	
			if (timeinfo.ticks > SUNRISE_START && timeinfo.ticks < SUNRISE_FINISH) {
			  float dist = IntToFloat(SUNRISE_FINISH - SUNRISE_START) - IntToFloat(timeinfo.ticks - SUNRISE_START);
			  
			  dark = 100 - FloatToInt((dist / IntToFloat(SUNRISE_FINISH - SUNRISE_START)) * 50.0);
				red = FloatToInt((dist / IntToFloat(SUNRISE_FINISH - SUNRISE_START)) * (-4.0));
			  blue = FloatToInt((dist / IntToFloat(SUNRISE_FINISH - SUNRISE_START)) * 8.0);
				
				stars = FloatToInt((dist / IntToFloat(SUNRISE_FINISH - SUNRISE_START)) * 99.0);
			}
      
			if (timeinfo.ticks >= SUNRISE_FINISH && timeinfo.ticks <= SUNSET_START) {
        dark = 100;
        red = 0;
        green = 0;
        blue = 0;
				stars = 1;
			}
      
			if (timeinfo.ticks >= SUNSET_FINISH || timeinfo.ticks < SUNRISE_START) {
        dark = 50;
        red = -4;
        green = 0;
        blue = 8;
				stars = 100;
			}
      
      dark += darknessOffset;
      
      if (isRaining) {
        if (blue == 0) 
          blue = 1;
        if (rainVisibility <= 0) {
          isRaining = false;
          isRainStopping = false;
        }
        else if (rainVisibility > 0 && rainVisibility <= 30) {
          if (!isRainStopping) rainVisibility += 4;
          else rainVisibility -= 4;
          blue += rainVisibility / 10;
          dark -= rainVisibility / 5;
        }
        else if (rainVisibility > 30) {
          if (isRainStopping) rainVisibility = 30;
          blue += 3;
          dark -= 7;
        }
        
      }

      SetDarkness(dark);
      SetTint(maxInt(red,  0), maxInt(green,  0), minInt(blue, 8));
      //SetTint(0, 0,  50);
      //SetTint2(0, 0, 0, 100, 0);
			drawStars(stars);
		}
		else {
			// interior
			//if (!GetFlashlightFollowCharacter()) {
			//	SetFlashlightDarkness(100);
			//	SetFlashlightTint(0, 0, 0);
			// }
		}
	  
		// next day
	  if (timeinfo.ticks > END_DAY) {
		  timeinfo.ticks = 0;
		  timeinfo.Day++;
		  //hungerd ++;
    }

}
function HandleTime() {

  if (IsTimerExpired(13) == 1) { 
    HandleRain();
    SetTimer(13, 2);
  }
	if (IsTimerExpired(10) == 1) { 
		timeinfo.ticks++;
		heroinfo.hunger++;
		heroinfo.thrist++;
		
		// Day and Night
		if (enableDayNightColourHandling) ProcessDayAndNight();
		
		
		SetTimer(10, 40);
 		HandleCharacter2();
  }
  
} �  // Script header for module 'Time'

import bool isday();
import function HandleTime();
import function SetDarkness(int dark);
import function SetTint(int red, int green, int blue);
import function SetTint2(int red, int green, int blue, int sat, int lum);
import function ProcessDayAndNight();
import function drawStars(int trans);
import function flushDrawStarsBuffer();
import short darknessOffset;
import function startRain();

import bool enableDayNightColourHandling;
 �]�z        ej��