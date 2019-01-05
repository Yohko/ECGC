#include <windows.h>
#include <iostream>
#include <unistd.h>
using namespace std;

bool isInt(const string& s){
   if(s.empty() || isspace(s[0])) return false;
   char *p ;
   strtol(s.c_str(), &p, 10);
   return (*p == 0);
}

int main(int argc, char *argv[]){
	// check if a parameter was given, we only consider the first one
	if(argc < 2){
		return 0;
	}
	// check if the parameter is a valid integer
	int i = 0;
	if(isInt(argv[1])){
		i = atoi(argv[1]);
	}else{
		return 0;
	}

	cout << "GC will be started after timer ends." << endl;
	
	// wait for the given time
	for(int j = 0;j<i;++j){
		cout << "\rT minus " << i-j << " seconds ";
		sleep(1); // sleep for 1 second
	}
	// activate the GC program
	HWND    hwndNotepad = FindWindowA(NULL,"Peaksimple - PeakSimple");
	SetForegroundWindow(hwndNotepad);
	// send "space" to start the GC
	keybd_event(VkKeyScan(' '),0,0,0);
	return 0;
}
