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
	char *file;
	char *token;
	for (;;) {
		file = getfile("/proc/version", buffer);
		file = strtok(file, "(")+13;
		file[strlen(file)-1] = '\0';
		char uname[30];
		sprintf(uname, "%s%s", "Linux", file);

		file = getfile("/proc/uptime", buffer);
		file = strtok(file, ".");
		int hours = atoi(file)/3600;
		int minutes = atoi(file)/60%60;
		char uptime[10];
		sprintf(uptime, "%02d:%02d", hours, minutes);

		char proc[] = "N/A";

		char active[] = "N/A";

		char cpu[] = "N/A";

		char memory[] = "N/A";

		file = getfile("/proc/net/dev", buffer);
		token = strtok(file, "\n");
		unsigned long long int netint = 0;
		while (token != NULL) {
			if (strstr(token, ":")) {
				token = strchr(token, ':')+2;
				char *ptr = strstr(token, " ");
				*ptr = '\0';
				netint += atoll(token);
			}
			token = strtok(NULL, "\n");
		}
		char netin[20];
		sprintf(netin, "%llu MiB", netint/1048576);

		file = getfile("/proc/net/dev", buffer);
		token = strtok(file, "\n");
		unsigned long long int netoutt = 0;
		while (token != NULL) {
			if (strstr(token, ":")) {
				token = strchr(token, ':')+2;
				token = strtok(token, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				netoutt += atoll(token);
			}
			token = strtok(NULL, "\n");
		}
		char netout[20];
		sprintf(netout, "%llu MiB", netoutt/1048576);

		file = getfile("/sys/class/power_supply/AC/online", buffer);
		file = strtok(file, "\n");
		char ac[2];
		if (file) {
			if (strcmp(file, "1") == 0) {
				ac[0] = 'Y';
			} else {
				ac[0] = 'N';
			}
		} else {
			ac[0] = 'Y';
		}
		ac[1] = '\0';

		char tempfilename[40];
		for (int i=0; i<5; i++) {
			sprintf(tempfilename, "%s%d%s", "/sys/class/hwmon/hwmon", i, "/name");
			file = getfile(tempfilename, buffer);
			file = strtok(file, "\n");
			if (file == 0) {
				break;
			}
			if (strcmp(file, "coretemp") == 0 || strcmp(file, "nct6775") == 0 || strncmp(file, "it87", 4) == 0 || strcmp(file, "k8temp") == 0 || strcmp(file, "k9temp") == 0 ) {
				break;
			}
		}
		tempfilename[strlen(tempfilename)-4] = '\0';
		strcat(tempfilename, "temp1_input");
		file = getfile(tempfilename, buffer);
		file = strtok(file, "\n");
		char temperature[5];
		if (file) {
			strcpy(temperature, file);
		} else {
			strcpy(temperature, "N/A");
		}
		temperature[strlen(temperature)-3] = 'C';
		temperature[strlen(temperature)-2] = '\0';

		file = getfile("/sys/class/power_supply/BAT0/capacity", buffer);
		if (file == 0) {
			file = getfile("/sys/class/power_supply/BAT1/capacity", buffer);
		}
		char battery[5];
		if (file) {
			file = strtok(file, "\n");
			strcpy(battery, file);
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
		if (strstr(brightnessfilename, "..") == NULL) {
			sprintf(brightness, "%d%s", atoi(getfile(brightnessfilename, buffer))*100/atoi(getfile(brightnessmaxfilename, buffer)), "%");
		} else {
			strcpy(brightness, "N/A");
		}

		char soundfilename[50];
		sprintf(soundfilename, "%s%s%s", "/home/", getenv("USER"), "/.asoundrc");
		file = getfile(soundfilename, buffer);
		if (file != 0) {
			file = strstr(file, "defaults.pcm.card ")+18;
			file = strtok(file, "\n");
			sprintf(soundfilename, "%s%s%s", "/proc/asound/card", file, "/codec#0");
		} else {
			strcpy(soundfilename, "/proc/asound/card0/codec#0");
		}
		file = getfile(soundfilename, buffer);
		char volume[5];
		if (file) {
			file = strstr(buffer, "Amp-Out vals:  ");
			file = strtok(file, "]");
			file = strrchr(file, ' ')+1;
			strcpy(volume, file);
			sprintf(volume, "%lu%%", strtol(volume, NULL, 16));
		} else {
			strcpy(volume, "N/A");
		}

		file = getfile("/proc/net/wireless", buffer);
		file = strtok(file, "\n");
		file = strtok(NULL, "\n");
		file = strtok(NULL, "\n");
		char wifi[5];
		if (file != NULL) {
			file = strtok(file, " ");
			file = strtok(NULL, " ");
			file = strtok(NULL, " ");
			file[strlen(file)-1] = '\0';
			sprintf(wifi, "%d%%", atoi(file)*100/70);
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
