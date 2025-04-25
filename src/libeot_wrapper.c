#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <emscripten.h>
#include <libeot/libeot.h>
#include <libeot/EOT.h>

// Wrapper for EOT2ttf functionality using filesystem API
EMSCRIPTEN_KEEPALIVE
int convertEOTtoTTF(const char* eotFilePath, const char* ttfFilePath) {
    FILE* eotFile = fopen(eotFilePath, "rb");
    if (!eotFile) {
        printf("Failed to open input file: %s\n", eotFilePath);
        return 1;
    }
    
    // Get file size
    fseek(eotFile, 0, SEEK_END);
    long eotSize = ftell(eotFile);
    fseek(eotFile, 0, SEEK_SET);
    
    // Allocate memory
    uint8_t* eotData = (uint8_t*)malloc(eotSize);
    if (!eotData) {
        printf("Memory allocation failed\n");
        fclose(eotFile);
        return 2;
    }
    
    // Read EOT file data
    fread(eotData, 1, eotSize, eotFile);
    fclose(eotFile);
    
    // Open output file
    FILE* ttfFile = fopen(ttfFilePath, "wb");
    if (!ttfFile) {
        printf("Failed to create output file: %s\n", ttfFilePath);
        free(eotData);
        return 3;
    }
    
    // Create metadata structure
    struct EOTMetadata metadata;
    
    // Call libeot library conversion function
    printf("Calling EOT2ttf_file function...\n");
    enum EOTError result = EOT2ttf_file(eotData, eotSize, &metadata, ttfFile);
    
    // Close output file
    fclose(ttfFile);
    
    // Free memory
    free(eotData);
    
    if (result != EOT_SUCCESS) {
        printf("Conversion failed, error code: %d\n", result);
        return 4;
    }
    
    printf("Conversion successful: %s -> %s\n", eotFilePath, ttfFilePath);
    return 0;
}

// Get error description
EMSCRIPTEN_KEEPALIVE
void getErrorDescription(int errorCode, char* buffer, int bufferSize) {
    switch (errorCode) {
        case 0:
            snprintf(buffer, bufferSize, "Success");
            break;
        case 1:
            snprintf(buffer, bufferSize, "Failed to open input file");
            break;
        case 2:
            snprintf(buffer, bufferSize, "Memory allocation failed");
            break;
        case 3:
            snprintf(buffer, bufferSize, "Failed to create output file");
            break;
        case 4:
            snprintf(buffer, bufferSize, "EOT to TTF conversion failed");
            break;
        default:
            snprintf(buffer, bufferSize, "Unknown error: %d", errorCode);
            break;
    }
}

int main() {
    printf("libeot WebAssembly module loaded\n");
    return 0;
}
