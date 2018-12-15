#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <dirent.h>
char *getfile(char *filename, char *buffer) {
	int size;
	FILE *fp;
	if ((fp = fopen(filename, "r"))) {
		size = fread(buffer, 1, 3000, fp);
		fclose(fp);
		buffer[size] = '\0';
		return buffer;
	} else {
		return 0;
	}
}
void main(void) {
	char buffer[3000];
	for (;;) {
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

		char *netdev = getfile("/proc/net/dev", buffer);
		char *token = strtok(netdev, "\n");
		char netin[500] = "";
		int netin2 = 0;
		while (token != NULL) {
			if (strstr(token, ":")) {
				token = strchr(token, ':')+2;
				char *ptr = strstr(token, " ");
				*ptr = '\0';
				strcat(netin, token);
				strcat(netin, "|");
				netin2 = netin2+atoi(token);
			}
			token = strtok(NULL, "\n");
		}
//		sprintf(netin, "%d MiB", netin2);

		char netout[500];

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
		tempfp = getfile(tempfilename, buffer);
		tempfp = strtok(tempfp, "\n");
		char temperature[5];
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
		char *volumehex;
		volumehex = getfile(soundfilename, buffer);
		char volume[5];
		if (volumehex) {
			volumehex = strstr(buffer, "Amp-Out vals:  ");
			volumehex = strtok(volumehex, "]");
			volumehex = strrchr(volumehex, ' ')+1;
			strcpy(volume, volumehex);
			sprintf(volume, "%lu%%", strtol(volume, NULL, 16));
		} else {
			strcpy(volume, "N/A");
		}

		char *netwireless = getfile("/proc/net/wireless", buffer);
		netwireless = strtok(netwireless, "\n");
		netwireless = strtok(NULL, "\n");
		netwireless = strtok(NULL, "\n");
		char wifi[5];
		if (strlen(netwireless) > 50) {
			netwireless = strtok(netwireless, " ");
			netwireless = strtok(NULL, " ");
			netwireless = strtok(NULL, " ");
			netwireless[strlen(netwireless)-1] = '\0';
			sprintf(wifi, "%d%%", atoi(netwireless)*100/70);
		} else {
			strcpy(wifi, "N/A");
		}

		time_t rawtime = time(NULL);
		struct tm *info = localtime(&rawtime);
		char date[40];
		strftime(date, 40, "%a %d %b %Y %H:%M:%S %Z", info);

		printf("\e[?25l\e[37m%s Up: \e[32m%s\e[37m Proc: \e[32m%s\e[37m Active: \e[32m%s\e[37m Cpu: \e[32m%s\e[37m Mem: \e[32m%s\e[37m Net in: \e[32m%s\e[37m Net out: \e[32m%s\e[37m AC: \e[32m%s\e[37m Temp: \e[32m%s\e[37m Battery: \e[32m%s\e[37m Brightness: \e[32m%s\e[37m Volume: \e[32m%s\e[37m Wifi: \e[32m%s\e[37m %s        \e[0m\r", uname, uptime, proc, active, cpu, memory, netin, netout, ac, temperature, battery, brightness, volume, wifi, date);
		fflush(stdout);
		nanosleep((struct timespec[]){{2, 0}}, NULL);
	}
}
