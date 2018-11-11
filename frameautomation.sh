#!/bin/bash
# Purpose: The goal of this script is to enable iFrame users to choose the turn ou/off and high/low brightness time and values for their particular device.
# Author: Raztou3D
# Date/Time: 06-11-2018.12:00

# The device's identification is done by the "FRAME_OWNER" environement variable, here is the list as of the 01.11.2018
# FRAME_OWNER			RESIN_DEVICE_NAME_AT_INIT	HOSTNAME	UUID
# Azad le beau-gosse	Azad						b820037		b8200373c08d1fce97fe4d0149b63b98
# Helen & Fabrizio		Helizio						d5be52a		d5be52adc2138ae4971d24071da8b2bc
# Mahmoud & Irène		Mahrene						81efc76		81efc766970805140f4c702fd31b84c8
# Reza & Anaïd			Rezaid						04d9b85		04d9b851f3b11da71a73d0b819a4bc31
# Katrin & Alexandre	Aletrin						3421be5		3421be5c955a708830118ba63fd46c71
# Edwin & Elsie			Dunki						3fd39aa		3fd39aae9c79b72b0f2a7fa78bf9a210

# Configuration table
#			+--------------------------+------------+
#           |         WEEK DAYS        |  WEEKENDS  |
# +---------+-----+------+------+------+-----+------+
# | Device  | ON1 | OFF1 | ON2  | OFF2 | ON3 | OFF3 |
# +---------+-----+------+------+------+-----+------+
# | Azad    |   6 |    9 |   17 |   23 |   7 |   23 |
# | Helizio |   6 |    9 |   17 |   23 |   7 |   23 |
# | Mahrene |   6 |    9 |   17 |   23 |   7 |   23 |
# | Rezaid  |   6 |    9 |   17 |   23 |   7 |   23 |
# | Aletrin |   6 |    9 |   17 |   23 |   7 |   23 |
# | Dunki   |   6 |   23 |    6 |   23 |   6 |   23 |
# +---------+-----+------+------+------+-----+------+
num_rows=7
num_columns=7
timelist0=(Device ON1 OFF1 ON2 OFF2 ON3 OFF3)
timelist1=(Azad 6 12 12 23 7 23)
timelist2=(Helizio 6 12 12 23 7 23)
timelist3=(Mahrene 6 12 12 23 7 23)
timelist4=(Rezaid 6 12 13 23 7 23)
timelist5=(Aletrin 6 12 12 23 7 23)
timelist6=(Dunki 6 12 12 23 6 23)

# Brightness values and time
HIGH=80 	# 80% screen brightness
LOW=40 		# 40% screen brightness
T_HIGH=10	# Turn screen brightness up at 10am
T_LOW=18    # turn screen brightness down at 6pm

# Get current hour (00..23)
NOW=$(date +"%H")
echo "Current time : $NOW"

# Get current week day (Monday = 1 ... Sunday = 7)
DOW=$(date +%u)
echo "Current week day : $DOW"

# Get device name
NAME=$RESIN_DEVICE_NAME_AT_INIT


# Automation per devices - Turn screen ON / OFF
for ((j=1;j<=num_columns;j++)); do
# Selects the array ligne of the device
    LOCAL_LIST="timelist${j}[0]"
    LOCAL_NAME=${!LOCAL_LIST}
	if [[ ${LOCAL_NAME[0]} = $NAME ]]; then 
		echo Found the device called $NAME.
		# On week days 
		if [ $DOW -le 5 ]; then 
		    echo Today is a week day.
            LOCAL_LIST="timelist${j}[@]"
            LOCAL_NAME=${!LOCAL_LIST}
            IFS=' ' read -r -a autotimes <<< ${LOCAL_NAME}
			if [[ $NOW -ge $((autotimes[1])) && $NOW -lt $((autotimes[2])) || $NOW -ge $((autotimes[3])) && $NOW -lt $((autotimes[4])) ]]; then
				# Turn screen ON
				echo 0 > /sys/class/backlight/rpi_backlight/bl_power
				echo Screen is now ON.
			elif [[ $NOW -lt $((autotimes[1])) || $NOW -ge $((autotimes[2])) && $NOW -lt $((autotimes[3])) || $NOW -ge $((autotimes[4])) ]]; then
				# Turn screen OFF
				echo 1 > /sys/class/backlight/rpi_backlight/bl_power
				echo Screen is now OFF.
			fi
		# On weekends
		else
		    echo Today is a weekend day.
			if [[ $NOW -ge $((autotimes[5])) && $NOW -lt $((autotimes[6])) ]]; then
				# Turn screen ON
				echo 0 > /sys/class/backlight/rpi_backlight/bl_power
				echo Screen is now ON.
				echo Screen brightness is now HIGH.
			elif [[ $NOW -ge $((autotimes[6])) && $NOW -lt $((autotimes[5])) ]]; then
				# Turn screen OFF
				echo 1 > /sys/class/backlight/rpi_backlight/bl_power
				echo Screen is now OFF.
			fi
		fi
		break
	else
	    echo Device not found in iteration $j.
	fi
done

# Automation set the brightness to HIGH / LOW
if [[ $NOW -ge $T_HIGH && $NOW -lt $T_LOW ]]; then
    # Turn brightness to HIGH
	echo $HIGH > /sys/class/backlight/rpi_backlight/brightness
	echo Screen brightness is now HIGH.
elif [[ $NOW -ge $T_LOW || $NOW -lt $T_HIGH ]]; then
	# Turn screen OFF
	echo $LOW > /sys/class/backlight/rpi_backlight/brightness
	echo Screen brightness is now LOW.
fi
