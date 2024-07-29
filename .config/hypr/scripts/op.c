#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define CAP(of, from, to) of = of > from ? of: from; of = of < to ? of: to
#define EXEC(buff, cmd...) sprintf(buff, cmd); system(buff)
#define MAXIMUM 1000

int main(int argc, char *argv[]) {
  char buff [1025] = {};
  if (argc < 3) {
    printf("Usage: %s <mode> <command>\n", argv[0]);
    return 1;
  }
  if (strcmp(argv[1], "brightness") == 0) {
    FILE *fp1 = popen("cat /sys/class/backlight/intel_backlight/brightness", "r");
    unsigned long _brightness;
    fscanf(fp1, "%1024lud", &_brightness);
    double brightness = (double)_brightness/960.0;
    double interv = 0.07 +  pow(tanh(brightness), 2.5)*(brightness + 1)*(pow(brightness, 1/7.5))/50.0;

    if (strcmp(argv[2], "up") == 0) {
      brightness += interv + 0.01;
    } else if (strcmp(argv[2], "down") == 0) {
      brightness -= interv;
    }

    CAP(brightness, 0, 100);
    EXEC(buff, "echo %d > /sys/class/backlight/intel_backlight/brightness", (int)(brightness * 960.0));
    EXEC(buff, "echo %d > /tmp/wobpipe", (int)(brightness * MAXIMUM / 100.0));

    pclose(fp1);
  }
  else if (strcmp(argv[1], "volume") == 0) {
    if (strcmp(argv[2], "up") == 0) {
      system("wpctl set-volume -l 2.0 @DEFAULT_SINK@ 2%+");
    } else if (strcmp(argv[2], "down") == 0) {
      system("wpctl set-volume -l 2.0 @DEFAULT_SINK@ 2%-");
    } else if (strcmp(argv[2], "toggle") == 0) {
      system("wpctl set-mute @DEFAULT_SINK@ toggle");
    }

    float vp;
    FILE *fp1 = popen("wpctl get-volume @DEFAULT_SINK@", "r");
    fscanf(fp1, "%*[^:]%*c%*[ ]%f%1024[^\n]", &vp, buff); // parse `Volume: 1.11 ?[MUTED]`
    vp /= 2;
    CAP(vp, 0, 1);
    if (strstr(buff,"MUTED") != NULL && vp > 0){
      EXEC(buff, "echo %d muted > /tmp/wobpipe", (int)(MAXIMUM*vp));
    } else {
      EXEC(buff, "echo %d > /tmp/wobpipe", (int)(MAXIMUM*vp));
    }
    pclose(fp1);
  }
  return 0;
}

//clang op.c -Ofast -fdelete-null-pointer-checks -fno-threadsafe-statics -s -ffast-math -lm -o ctrl
