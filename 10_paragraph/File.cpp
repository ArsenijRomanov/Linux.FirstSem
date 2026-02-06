#include <iostream>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdexcept>
#include <string>

template <class T>
inline T check(T ret)
{
	if (ret == T(-1))
		throw std::system_error(errno, std::generic_category());
	return ret;
}

class File
{
private:
	int fd;

public:
	File(const std::string &filename, int flags, mode_t mode = 0644)
	{
		fd = check(open(filename.c_str(), flags, mode));
	}

	~File()
	{
		if (fd != -1)
			check(close(fd));
	}

	void writeToFile(const std::string &data)
	{
		ssize_t nwritten = check(write(fd, data.c_str(), data.size()));
		std::cout << "Byte recorded: " << nwritten << std::endl;
	}

	std::string readFromFile(size_t size)
	{
		char buffer[size];
		ssize_t nread = check(read(fd, buffer, size));
		return std::string(buffer, nread);
	}

	File(File &&rhs)
	{
		fd = rhs.fd;
		rhs.fd = -1;
	}

	File &operator=(File &&rhs)
	{
		if (this != &rhs)
		{
			if (fd != -1)
				check(close(fd));

			fd = rhs.fd;
			rhs.fd = -1;
		}
		return *this;
	}

	off_t getPosition()
	{
		off_t position = check(lseek(fd, 0, SEEK_CUR));
		return position;
	}

	void setPosition(off_t offset)
	{
		check(lseek(fd, offset, SEEK_SET));
	}

	File(const File &rhs)
	{
		fd = check(dup(rhs.fd));
	}

	File &operator=(const File &rhs)
	{
		if (this != &rhs)
		{
			if (fd != -1)
				check(close(fd));

			fd = check(dup2(rhs.fd, fd));
		}
		return *this;
	}
};

int main()
{
	try
	{
		File file("testfile.txt", O_CREAT | O_WRONLY | O_TRUNC);

		file.writeToFile("Hello, World!\n");

		File fileRead("testfile.txt", O_RDONLY);

		std::string content = fileRead.readFromFile(256);
		std::cout << "File contents: " << content << std::endl;

		File movedFile = std::move(fileRead);
		movedFile.setPosition(0);
		std::string movedContent = movedFile.readFromFile(256);
		std::cout << "Moved file contents: " << movedContent << std::endl;
	}
	catch (const std::system_error &e)
	{
		std::cerr << "Error: " << e.what() << std::endl;
	}

	return 0;
}

// valgrind --track-fds=yes ./a.out
