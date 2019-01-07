// Licence: GNU General Public License version 2 (GPLv2)
// For starting a SRI GC within EC-Lab using the "external application technique"
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

	HINSTANCE hDLL = LoadLibraryW (L"user32.dll");
	if (hDLL == NULL){
		cout << "Failed to load user32.dll" << endl;
		return 0;
	}
	typedef BOOL (WINAPI *BLOCKINPUT)(BOOL);
	BLOCKINPUT pBlockInput;
	pBlockInput = (BLOCKINPUT)GetProcAddress (hDLL, "BlockInput");
    if(pBlockInput == NULL){
		cout << "Failed to import BlockInput" << endl;
		FreeLibrary(hDLL);
		return 0;
    }

	cout << "GC will be started after timer ends." << endl;

	// wait for the given time
	for(int j = 0;j<i;++j){
		cout << "\rT minus " << i-j << " seconds ";
		sleep(1); // sleep for 1 second
	}

	// block user input as this sometimes can interfere with starting the GC
	// this needs Administrator privileges
	BOOL res = pBlockInput(TRUE);
	if(!res){
		cout << "BlockInput failed" << endl;
	}else{
		cout << "BlockInput was successful." << endl;
	}	
	sleep(1);

	// activate the GC program
	HWND    hwndGC = FindWindowA(NULL,"Peaksimple - PeakSimple");
	SetForegroundWindow(hwndGC);

	// send "space" to start the GC
	keybd_event(VkKeyScan(' '),0,0,0);

	// wait a second and unblock user input
	sleep(1);
	pBlockInput(FALSE);

	FreeLibrary(hDLL);
	return 0;
}
