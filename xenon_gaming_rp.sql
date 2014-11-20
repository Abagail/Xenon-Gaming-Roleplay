-- phpMyAdmin SQL Dump
-- version 4.1.6
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Sep 11, 2014 at 04:44 PM
-- Server version: 5.6.16
-- PHP Version: 5.5.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `dbdb`
--

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE IF NOT EXISTS `bans` (
  `IP` text NOT NULL,
  `Reason` text NOT NULL,
  `Name` text NOT NULL,
  `Date` date NOT NULL,
  `BanExp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `config`
--

CREATE TABLE IF NOT EXISTS `config` (
  `unknowncmd` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE IF NOT EXISTS `inventory` (
  `ItemModel` int(11) NOT NULL,
  `ItemPosX` int(11) NOT NULL,
  `ItemPosY` int(11) NOT NULL,
  `ItemPosZ` int(11) NOT NULL,
  `ItemRotX` int(11) NOT NULL,
  `ItemRotY` int(11) NOT NULL,
  `ItemRotZ` int(11) NOT NULL,
  `ItemVWorld` int(11) NOT NULL,
  `ItemInterior` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE IF NOT EXISTS `players` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(24) NOT NULL,
  `pass` varchar(129) NOT NULL,
  `IP` varchar(16) NOT NULL,
  `Admin` int(11) NOT NULL,
  `Vip` int(11) NOT NULL,
  `Money` int(11) NOT NULL,
  `Score` int(11) NOT NULL,
  `TrustedLevel` int(11) NOT NULL,
  `Deaths` int(11) NOT NULL,
  `Kills` int(11) NOT NULL,
  `X` float NOT NULL,
  `Y` float NOT NULL,
  `Z` float NOT NULL,
  `FacingAngle` float NOT NULL,
  `Interior` int(11) NOT NULL,
  `VW` int(11) NOT NULL,
  `SkinID` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE IF NOT EXISTS `settings` (
  `MOTD` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`MOTD`) VALUES
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!'),
('Welcome to Xenon Gaming RP!');

-- --------------------------------------------------------

--
-- Table structure for table `spawnpoint`
--

CREATE TABLE IF NOT EXISTS `spawnpoint` (
  `X` float NOT NULL,
  `Y` float NOT NULL,
  `Z` float NOT NULL,
  `Angle` float NOT NULL,
  UNIQUE KEY `X` (`X`,`Y`,`Z`,`Angle`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `spawnpoint`
--

INSERT INTO `spawnpoint` (`X`, `Y`, `Z`, `Angle`) VALUES
(-182.836, 1132.67, 19.7422, 0);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
