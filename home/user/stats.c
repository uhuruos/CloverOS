#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <dirent.h>
char *getfile(char *filename, char *buffer) {
	FILE *fp;
	if ((fp = fopen(filename, "r"))) {
		fread(buffer, 1, 40, fp);
		fclose(fp);
		return buffer;
	} else {
		return 0;
	}
}
void main(void) {
	char buffer[40];
	while (1) {
		char *unamefp = getfile("/proc/version", buffer);
		unamefp = strtok(unamefp, "(")+13;
		unamefp[strlen(unamefp)-1] = '\0';
		char uname[30];
		sprintf(uname, "%s%s", "Linux", unamefp);

		char *uptimefp = getfile("/proc/uptime", buffer);
		uptimefp = strtok(uptimefp, ".");
		int hours = atoi(uptimefp)/3600;
		int minutes = atoi(uptimefp)/60%60;
		char uptime[10];
		sprintf(uptime, "%02d:%02d", hours, minutes);

		char proc[] = "N/A";

		char active[] = "N/A";

		char cpu[] = "N/A";

		char memory[] = "N/A";

		char netin[] = "N/A";

		char netout[] = "N/A";

		char *acfp = getfile("/sys/class/power_supply/AC/online", buffer);
		acfp = strtok(acfp, "\n");
		char ac[2];
		if (acfp) {
			if (strcmp(acfp, "1") == 0) {
				ac[0] = 'Y';
			} else {
				ac[0] = 'N';
			}
		} else {
			ac[0] = 'Y';
		}
		ac[1] = '\0';

		char *tempfp;
		char tempfilename[40];
		for (int i=0; i<5; i++) {
			sprintf(tempfilename, "%s%d%s", "/sys/class/hwmon/hwmon", i, "/name");
			tempfp = getfile(tempfilename, buffer);
			tempfp = strtok(tempfp, "\n");
			if (tempfp == 0) {
				break;
			}
			if (strcmp(tempfp, "coretemp") == 0 || strcmp(tempfp, "k8temp") == 0 || strcmp(tempfp, "k9temp") == 0 || strcmp(tempfp, "k10temp") == 0 || strcmp(tempfp, "nct6775") == 0 || strncmp(tempfp, "it87", 4) == 0 ) {
				break;
			}
		}
		tempfilename[strlen(tempfilename)-4] = '\0';
		strcat(tempfilename, "temp1_input");
		char temperature[4];
		tempfp = getfile(tempfilename, buffer);
		tempfp = strtok(tempfp, "\n");
		if (tempfp) {
			strcpy(temperature, tempfp);
		} else {
			strcpy(temperature, "N/A");
		}
		temperature[strlen(temperature)-3] = 'C';
		temperature[strlen(temperature)-2] = '\0';

		char *batteryfp = getfile("/sys/class/power_supply/BAT0/capacity", buffer);
		if (batteryfp == 0) {
			batteryfp = getfile("/sys/class/power_supply/BAT1/capacity", buffer);
		}
		char battery[5];
		if (batteryfp) {
			batteryfp = strtok(batteryfp, "\n");
			strcpy(battery, batteryfp);
			strcat(battery, "%");
		} else {
			strcpy(battery, "N/A");
		}

		char brightnessfilename[70];
		char brightnessmaxfilename[70];
		DIR *dp;
		struct dirent *dir;
		dp = opendir("/sys/class/backlight/");
		while ((dir = readdir(dp)) != NULL) {
			sprintf(brightnessmaxfilename, "%s%s%s", "/sys/class/backlight/", dir->d_name, "/max_brightness");
			sprintf(brightnessfilename, "%s%s%s", "/sys/class/backlight/", dir->d_name, "/actual_brightness");
		}
		closedir(dp);
		char brightness[5];
		if (brightnessfilename != '\0' && brightnessfilename) {
			sprintf(brightness, "%d%s", atoi(getfile(brightnessfilename, buffer))*100/atoi(getfile(brightnessmaxfilename, buffer)), "%");
		} else {
			strcpy(brightness, "N/A");
		}

		char soundfilename[50];
		sprintf(soundfilename, "%s%s%s", "/home/", getenv("USER"), "/.asoundrc");
		char *asoundrc = getfile(soundfilename, buffer);
		if (asoundrc != 0) {
			asoundrc = strstr(asoundrc, "defaults.pcm.card ")+18;
			asoundrc = strtok(asoundrc, "\n");
			sprintf(soundfilename, "%s%s%s", "/proc/asound/card", asoundrc, "/codec#0");
		} else {
			strcpy(soundfilename, "/proc/asound/card0/codec#0");
		}
		char volume[5];
		FILE *fp;
		if ((fp = fopen(soundfilename, "r"))) {
			char buffer[9999];
			fread(buffer, 1, 9999, fp);
			fclose(fp);
			char *volumehex;
			volumehex = strstr(buffer, "Amp-Out vals:  ");
			volumehex = strtok(volumehex, "]");
			volumehex = strrchr(volumehex, ' ')+1;
			strcpy(volume, volumehex);
			sprintf(volume, "%lu%%", strtol(volume, NULL, 16));
		} else {
			strcpy(volume, "N/A");
		}

		char wifi[] = "N/A";

		time_t rawtime = time(NULL);
		struct tm *info = localtime(&rawtime);
		char date[40];
		strftime(date, 40, "%a %d %b %Y %H:%M:%S %Z", info);

		printf("\e[?25l\e[37m%s Up: \e[32m%s\e[37m Proc: \e[32m%s\e[37m Active: \e[32m%s\e[37m Cpu: \e[32m%s \e[37mMem: \e[32m%s\e[37m Net in: \e[32m%s\e[37m Net out: \e[32m%s\e[37m AC: \e[32m%s\e[37m Temp: \e[32m%s\e[37m Battery: \e[32m%s\e[37m Brightness: \e[32m%s\e[37m Volume: \e[32m%s\e[37m Wifi: \e[32m%s\e[37m %s        \e[0m\r", uname, uptime, proc, active, cpu, memory, netin, netout, ac, temperature, battery, brightness, volume, wifi, date);
		fflush(stdout);
		nanosleep((struct timespec[]){{2, 0}}, NULL);
	}
}
