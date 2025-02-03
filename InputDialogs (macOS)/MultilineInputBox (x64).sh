cd "${0%/*}"
g++ -c -std=c++17 "MultilineInputBox.part1.cpp" -fPIC -mmacos-version-min=10.13 -arch arm64 -arch x86_64
g++ -c -ObjC "MultilineInputBox.part2.mm" "NSAlert+SynchronousSheet.mm" "NSNumberFormatter.mm" -fPIC -mmacos-version-min=10.13 -arch arm64 -arch x86_64
g++ "MultilineInputBox.part1.o" "MultilineInputBox.part2.o" "NSAlert+SynchronousSheet.o" "NSNumberFormatter.o" -o "MultilineInputBox (x64)/MultilineInputBox.dylib" -shared -framework Cocoa -fPIC -mmacos-version-min=10.13 -arch arm64 -arch x86_64
