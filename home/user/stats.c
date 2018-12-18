#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <dirent.h>
#include <alsa/output.h>
#include <alsa/input.h>
#include <alsa/global.h>
#include <alsa/conf.h>
#include <alsa/control.h>
#include <alsa/pcm.h>
#include <alsa/mixer.h>
char *getfile(char *filename, char *buffer) {
	FILE *fp;
	if ((fp = fopen(filename, "r"))) {
		int size = fread(buffer, 1, 3000, fp);
		fclose(fp);
		buffer[size] = '\0';
		return buffer;
	} else {
		return 0;
	}
}
void main(void) {
	char buffer[3000], *file;
	for (;;) {
		file = getfile("/proc/version", buffer);
		file = file+14;
		*strchr(file, ' ') = '\0';
		char uname[30];
		sprintf(uname, "%s%s", "Linux ", file);

		file = getfile("/proc/uptime", buffer);
		*strchr(file, '.') = '\0';
		int hours = atoi(file)/3600;
		int minutes = atoi(file)/60%60;
		char uptime[10];
		sprintf(uptime, "%02d:%02d", hours, minutes);

		int processesi = 0;
		DIR *dp;
		struct dirent *dir;
		dp = opendir("/proc/");
		while ((dir = readdir(dp)) != NULL) {
			if (dir->d_name[0] >= '0' && dir->d_name[0] <= '9') {
				processesi++;
			}
		}
		closedir(dp);
		char processes[10];
		sprintf(processes, "%d", processesi);

		file = getfile("/proc/stat", buffer);
		file = strstr(file, "procs_running ")+14;
		*strchr(file, '\n') = '\0';
		char active[5];
		strcpy(active, file);

		file = getfile("/proc/stat", buffer);
		*strchr(file, '\n') = '\0';
		file = file+3;
		unsigned long long int cputotal = 0, cpuidle = 0, cpulasttotal, cpulastidle;
		cputotal += atoll(strtok(file, " "));
		for (int i = 0; i < 2; i++, cputotal += atoll(strtok(NULL, " ")));
		char *cputoken = strtok(NULL, " ");
		cpuidle += atoll(cputoken);
		cputotal += atoll(cputoken);
		for (int i = 0; i < 6; i++, cputotal += atoll(strtok(NULL, " ")));
		char cpu[20];
		sprintf(cpu, "%llu%%", (1000*((cputotal-cpulasttotal)-(cpuidle-cpulastidle))/(cputotal-cpulasttotal)+5)/10);
		cpulasttotal = cputotal;
		cpulastidle = cpuidle;

		file = getfile("/proc/meminfo", buffer);
		char memory[50];
		strncpy(memory, strstr(file, "MemTotal: ")+10, 50); *strstr(memory, " kB") = '\0'; *strrchr(memory, ' ')+1;
		unsigned long long int memtotal = atoll(memory);
		strncpy(memory, strstr(file, "MemFree: ")+9, 50); *strstr(memory, " kB") = '\0'; *strrchr(memory, ' ')+1;
		unsigned long long int memfree = atoll(memory);
		strncpy(memory, strstr(file, "Buffers: ")+9, 50); *strstr(memory, " kB") = '\0'; *strrchr(memory, ' ')+1;
		unsigned long long int buffers = atoll(memory);
		strncpy(memory, strstr(file, "Cached: ")+8, 50); *strstr(memory, " kB") = '\0'; *strrchr(memory, ' ')+1;
		unsigned long long int cached = atoll(memory);
		strncpy(memory, strstr(file, "Shmem: ")+7, 50); *strstr(memory, " kB") = '\0'; *strrchr(memory, ' ')+1;
		unsigned long long int shmem = atoll(memory);
		strncpy(memory, strstr(file, "SReclaimable: ")+14, 50); *strstr(memory, " kB") = '\0'; *strrchr(memory, ' ')+1;
		unsigned long long int sreclaimable = atoll(memory);
		sprintf(memory, "%llu MiB / %llu MiB", (memtotal+shmem-memfree-buffers-cached-sreclaimable)/1024, memtotal/1024);

		file = getfile("/proc/net/dev", buffer);
		file = strchr(file, '\n')+1;
		file = strchr(file, '\n')+1;
		int x;
		for (int i = x = 1; file[i]; ++i) {
			if (file[i] != ' ' || file[i-1] != ' ') {
				file[x++] = file[i];
			}
		}
		file[x] = '\0';
		unsigned long long int netint = 0, netoutt = 0;
		char *token;
		token = strtok(file, "\n");
		while (token != NULL) {
			token = strchr(token, ':')+1;
			token = token+1;
			char *buf;
			strtok_r(token, " ", &buf);
			netint += atoll(token);
			for (int i = 0; i < 8; i++, token = strtok_r(NULL, " ", &buf));
			netoutt += atoll(token);
			token = strtok(NULL, "\n");
		}
		char netin[20], netout[20];
		sprintf(netin, "%llu MiB", netint/1048576);
		sprintf(netout, "%llu MiB", netoutt/1048576);

		file = getfile("/sys/class/power_supply/AC/online", buffer);
		char ac[2];
		if (file) {
			file[strlen(file)-1] = '\0';
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
		for (int i = 0; i < 5; i++) {
			sprintf(tempfilename, "%s%d%s", "/sys/class/hwmon/hwmon", i, "/name");
			file = getfile(tempfilename, buffer);
			*strchr(file, '\n') = '\0';
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
		char temperature[5];
		if (file) {
			file[strlen(file)-4] = 'C';
			file[strlen(file)-3] = '\0';
			strcpy(temperature, file);
		} else {
			strcpy(temperature, "N/A");
		}

		file = getfile("/sys/class/power_supply/BAT0/capacity", buffer);
		if (file == 0) {
			file = getfile("/sys/class/power_supply/BAT1/capacity", buffer);
		}
		char battery[5];
		if (file) {
			*strchr(file, '\n') = '\0';
			strcat(file, "%");
			strcpy(battery, file);
		} else {
			strcpy(battery, "N/A");
		}

		char brightnessfilename[70];
		char brightnessmaxfilename[70];
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


		long int minv, maxv, outvol;
		snd_mixer_t *handle;
		snd_mixer_elem_t *elem;
		snd_mixer_selem_id_t *sid;
		snd_mixer_open(&handle, 0);
		snd_mixer_attach(handle, "default");
		snd_mixer_selem_register(handle, NULL, NULL);
		snd_mixer_load(handle);
		snd_mixer_selem_id_malloc(&sid);
		snd_mixer_selem_id_set_index(sid, 0);
		snd_mixer_selem_id_set_name(sid, "Master");
		elem = snd_mixer_find_selem(handle, sid);
		snd_mixer_selem_get_playback_volume_range(elem, &minv, &maxv);
		snd_mixer_selem_get_playback_volume(elem, 0, &outvol);
		outvol = outvol + (minv * (-1));
		outvol = ((float)(outvol + (minv * (-1))) / (maxv + (minv * (-1)))) * 100;
		snd_mixer_detach(handle, "default");
		snd_mixer_close(handle);
		snd_mixer_selem_id_free(sid);
		char volume[5];
		sprintf(volume, "%ld%%", outvol);

		file = getfile("/proc/net/wireless", buffer);
		file = strchr(file, '\n')+1;
		file = strchr(file, '\n')+1;
		char wifi[5];
		if (*file) {
			strtok(file, " ");
			for (int i = 0; i < 2; i++, file = strtok(NULL, " "));
			file[strlen(file)-1] = '\0';
			sprintf(wifi, "%d%%", atoi(file)*100/70);
		} else {
			strcpy(wifi, "N/A");
		}

		time_t rawtime = time(NULL);
		struct tm *info = localtime(&rawtime);
		char date[40];
		strftime(date, 40, "%a %d %b %Y %H:%M:%S %Z", info);

		printf("\e[?25l\e[37m%s Up: \e[32m%s\e[37m Proc: \e[32m%s\e[37m Active: \e[32m%s\e[37m Cpu: \e[32m%s\e[37m Mem: \e[32m%s\e[37m Net in: \e[32m%s\e[37m Net out: \e[32m%s\e[37m AC: \e[32m%s\e[37m Temp: \e[32m%s\e[37m Battery: \e[32m%s\e[37m Brightness: \e[32m%s\e[37m Volume: \e[32m%s\e[37m Wifi: \e[32m%s\e[37m %s        \e[0m\r", uname, uptime, processes, active, cpu, memory, netin, netout, ac, temperature, battery, brightness, volume, wifi, date);
		fflush(stdout);
		nanosleep((struct timespec[]){{2, 0}}, NULL);
	}
}
