function Test()
	-- Test for a clean directory.
	local originalFiles =
	{
		'Jamfile.jam',
		'main.cpp',
		'mypch.cpp',
		'includes/mypch.h',
		'includes/usefuldefine.h',
	}

	local originalDirs =
	{
		'includes/',
	}

	RunJam{ 'clean' }
	TestDirectories(originalDirs)
	TestFiles(originalFiles)

	---------------------------------------------------------------------------
	local pass1Directories
	local pass1Files
	local pattern

	if Platform == 'win32' and not Compiler then
		pass1Directories = {
			'includes/',
		}

		pass1Files = {
			'Jamfile.jam',
			'main.cpp',
			'main.obj',
			'main.release.exe',
			'main.release.exe.intermediate.manifest',
			'main.release.pdb',
			'mypch.cpp',
			'mypch.h.pch',
			'mypch.obj',
			'test.lua',
			'vc.pdb',
			'includes/mypch.h',
			'includes/usefuldefine.h',
		}

		pass1Pattern = [[
			*** found 17 target(s)...
			*** updating 4 target(s)...
			@ C.C++ <main>mypch.h.pch
			mypch.cpp
			@ C.C++ <main>main.obj
			main.cpp
			@ C.LinkWithManifest <main>main.release.exe
			*** updated 4 target(s)...
]]

		pass2Pattern = [[
			*** found 17 target(s)...
			*** updating 4 target(s)...
			@ C.C++ <main>mypch.h.pch
			mypch.cpp
			@ C.C++ <main>main.obj
			main.cpp
			@ C.LinkWithManifest <main>main.release.exe
			*** updated 4 target(s)...
]]
	elseif Compiler == 'mingw' then
		pass1Directories = {
			'includes/',
			'mypch%-%x+/',
		}

		pass1Files = {
			'Jamfile.jam',
			'main.cpp',
			'main.o',
			'main.release.exe',
			'mypch.cpp',
			'mypch.o',
			'test.lua',
			'includes/mypch.h',
			'includes/usefuldefine.h',
			'mypch%-%x+/mypch.h.gch',
		}

		pass1Pattern = [[
			*** found 14 target(s)...
			*** updating 5 target(s)...
			&@ C.PCH <main%-%x+>mypch.h.gch
			@ C.C++ <main>main.o 
			@ C.C++ <main>mypch.o 
			@ C.Link <main>main.release.exe
			*** updated 5 target(s)...
]]

		pass2Pattern = [[
			*** found 14 target(s)...
			*** updating 5 target(s)...
			&@ C.PCH <main%-%x+>mypch.h.gch
			@ C.C++ <main>main.o 
			@ C.C++ <main>mypch.o 
			@ C.Link <main>main.release.exe
			*** updated 5 target(s)...
]]
	else
		pass1Directories = {
			'includes/',
			'mypch%-%x+/',
		}

		pass1Files = {
			'Jamfile.jam',
			'main.cpp',
			'main.o',
			'main.release',
			'mypch.cpp',
			'mypch.o',
			'test.lua',
			'includes/mypch.h',
			'includes/usefuldefine.h',
			'mypch%-%x+/mypch.h.gch',
		}

		pass1Pattern = [[
			*** found 14 target(s)...
			*** updating 5 target(s)...
			&@ C.PCH <main%-%x+>mypch.h.gch
			@ C.C++ <main>main.o 
			@ C.C++ <main>mypch.o 
			@ C.Link <main>main.release 
			*** updated 5 target(s)...
]]

		pass2Pattern = [[
			*** found 14 target(s)...
			*** updating 4 target(s)...
			&@ C.PCH <main%-%x+>mypch.h.gch
			@ C.C++ <main>main.o 
			@ C.C++ <main>mypch.o 
			@ C.Link <main>main.release 
			*** updated 4 target(s)...
]]
	end

	TestPattern(pass1Pattern, RunJam{})
	TestDirectories(pass1Directories)
	TestFiles(pass1Files)

	---------------------------------------------------------------------------
	local pattern2
	if Platform == 'win32' and Compiler ~= 'mingw' then
		pattern2 = [[
*** found 17 target(s)...
]]
	else
		pattern2 = [[
*** found 14 target(s)...
]]
	end
	TestPattern(pattern2, RunJam{})
	TestDirectories(pass1Directories)
	TestFiles(pass1Files)
	
	---------------------------------------------------------------------------
	os.sleep(1)
	os.touch('includes/usefuldefine.h')
	TestPattern(pass2Pattern, RunJam{})
	TestDirectories(pass1Directories)
	TestFiles(pass1Files)

	---------------------------------------------------------------------------
	TestPattern(pattern2, RunJam{})
	TestDirectories(pass1Directories)
	TestFiles(pass1Files)

	---------------------------------------------------------------------------
	RunJam{ 'clean' }
	TestFiles(originalFiles)
	TestDirectories(originalDirs)
end
