#!/bin/bash

# !!!!!!Add sudo if you run this script not as a root user!!!!!
# Then uncomment next line
# sudo su
echo "Apt update"

apt-get update 

# DOCKER
echo "✔️ Check Docker"

if command -v docker &> /dev/null; then
	echo "Docker installation found"
else
	echo "Docker installation not found. Installing docker."
	apt-get install -y ca-certificates curl
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	chmod a+r /etc/apt/keyrings/docker.asc
	
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
	tee /etc/apt/sources.list.d/docker.list > /dev/null

	apt update -y
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	echo "Verify docker installation"
	docker run hello-world

	echo "Adding current user ($USER) to the 'docker' group..."
	usermod -aG docker "$USER"
fi

# PYTHON3
echo "✔️ Check Python version"
if command -v python3 &> /dev/null; then
	python3_version=$(python3 -V 2>&1 | cut -d' ' -f2)
	if [[ "$python3_version" < "3.9" ]]; then
		echo "Python version is $python3_version — upgrading to 3.9..."
		apt install -y software-properties-common
		add-apt-repository ppa:deadsnakes/ppa -y
		apt update -y
		apt install -y python3.9 python3.9-venv python3.9-dev
		update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
	fi
else
	echo "Python not found — installing 3.9..."
	apt install -y software-properties-common
	add-apt-repository ppa:deadsnakes/ppa -y
	apt update -y
	apt install -y python3.9 python3.9-venv python3.9-dev
	update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
fi

echo "Python version: $(python3 --version)"

# PIP
echo "✔️ Check pip"

if command -v pip3 &> /dev/null; then
	echo "Pip is installed; version - $(pip3 --version)"
else
	echo "Installing pip..."
	apt install -y python3-pip
	echo "Pip version - $(pip3 --version)"
fi

# DJANGO
echo "✔️ Check Django"

pip3 show Django &> /dev/null
if [ $? -eq 0 ]; then
	echo "Django already installed: $(django-admin --version)"
else
	echo "Installing Django..."
	pip3 install Django
	echo "Django installed: $(django-admin --version)"
fi