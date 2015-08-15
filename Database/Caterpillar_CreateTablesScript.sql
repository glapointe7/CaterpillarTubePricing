SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `Caterpillar` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `Caterpillar` ;

-- -----------------------------------------------------
-- Table `Caterpillar`.`ComponentType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`ComponentType` (
  `pkComponentType` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`pkComponentType`),
  UNIQUE INDEX `pkComponentType_UNIQUE` (`pkComponentType` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`ConnectionType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`ConnectionType` (
  `pkConnectionType` INT NOT NULL AUTO_INCREMENT,
  `ConnectionTypecol` VARCHAR(100) NOT NULL,
  UNIQUE INDEX `pkConnectionType_UNIQUE` (`pkConnectionType` ASC),
  PRIMARY KEY (`pkConnectionType`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeEndForm`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeEndForm` (
  `pkTubeEndForm` INT NOT NULL AUTO_INCREMENT,
  `forming` BIT NOT NULL,
  UNIQUE INDEX `pkTubeEndForm_UNIQUE` (`pkTubeEndForm` ASC),
  PRIMARY KEY (`pkTubeEndForm`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component` (
  `pkComponent` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `fkComponentType` INT NOT NULL,
  `orientation` BIT NULL,
  `weight` DECIMAL(8,2) NULL,
  UNIQUE INDEX `pkComponent_UNIQUE` (`pkComponent` ASC),
  PRIMARY KEY (`pkComponent`),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`EndFormType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`EndFormType` (
  `pkEndFormType` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`pkEndFormType`),
  UNIQUE INDEX `pkEndFormType_UNIQUE` (`pkEndFormType` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeAssembly`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssembly` (
  `pkTubeAssembly` INT NOT NULL AUTO_INCREMENT,
  `TubeAssemblycol` VARCHAR(20) NULL,
  `TubeAssemblycol1` DECIMAL(8,2) NULL,
  `wallThickness` DECIMAL(8,2) NULL,
  `length` INT NULL,
  `numberOfBends` INT NULL,
  `bendRadius` DECIMAL(8,2) NULL,
  `endA1X` BIT NULL,
  `endA2X` BIT NULL,
  `endX1X` BIT NULL,
  `endX2X` BIT NULL,
  `fkTubeEndFormA` INT NULL,
  `fkTubeEndFormX` INT NULL,
  `numberOfBoss` INT NULL,
  `numberOfBracket` INT NULL,
  `other` INT NULL,
  `specs` VARCHAR(150) NULL,
  PRIMARY KEY (`pkTubeAssembly`),
  UNIQUE INDEX `pkTubeAssembly_UNIQUE` (`pkTubeAssembly` ASC),
  INDEX `fkTubeEndFormA_idx` (`fkTubeEndFormA` ASC),
  INDEX `fkTubeEndFormX_idx` (`fkTubeEndFormX` ASC),
  CONSTRAINT `fkTubeEndFormA`
    FOREIGN KEY (`fkTubeEndFormA`)
    REFERENCES `Caterpillar`.`TubeEndForm` (`pkTubeEndForm`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkTubeEndFormX`
    FOREIGN KEY (`fkTubeEndFormX`)
    REFERENCES `Caterpillar`.`TubeEndForm` (`pkTubeEndForm`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeAssembly_Component`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssembly_Component` (
  `fkTubeAssembly` INT NOT NULL,
  `fkComponent` INT NOT NULL,
  `quantity` INT NULL,
  INDEX `fkTubeAssembly_idx` (`fkTubeAssembly` ASC),
  INDEX `fkComponent_idx` (`fkComponent` ASC),
  CONSTRAINT `fkTubeAssembly`
    FOREIGN KEY (`fkTubeAssembly`)
    REFERENCES `Caterpillar`.`TubeAssembly` (`pkTubeAssembly`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeAssemblyPricing`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssemblyPricing` (
  `pkTubeAssemblyPricing` INT NOT NULL AUTO_INCREMENT,
  `fkTubeAssembly` INT NOT NULL,
  `supplierID` VARCHAR(20) NOT NULL,
  `quoteDate` DATE NOT NULL,
  `anualUsage` INT NOT NULL,
  `minOrderQuantity` INT NOT NULL,
  `bracketPricing` BIT NOT NULL,
  `quantity` INT NOT NULL,
  `cost` DECIMAL(18,10) NOT NULL,
  PRIMARY KEY (`pkTubeAssemblyPricing`),
  UNIQUE INDEX `pkTubeAssemblyPricing_UNIQUE` (`pkTubeAssemblyPricing` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Sleeve`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Sleeve` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `fkConnectionType` INT NULL,
  `length` DECIMAL(8,2) NULL,
  `intendedNutThread` DECIMAL(8,3) NULL,
  `intendedNutPitch` DECIMAL(8,2) NULL,
  `uniqueFeature` BIT NULL,
  `plating` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  INDEX `fkConnectionType_idx` (`fkConnectionType` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkConnectionType`
    FOREIGN KEY (`fkConnectionType`)
    REFERENCES `Caterpillar`.`ConnectionType` (`pkConnectionType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Straight`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Straight` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `boltPatternLong` DECIMAL(8,2) NULL,
  `boltPatternWide` DECIMAL(8,2) NULL,
  `headDiameter` DECIMAL(8,2) NULL,
  `overallLength` DECIMAL(8,2) NULL,
  `thickness` DECIMAL(8,2) NULL,
  `mjClassCode` VARCHAR(25) NULL,
  `groove` BIT NULL,
  `uniqueFeature` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Tee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Tee` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `boltPatternLong` DECIMAL(8,2) NULL,
  `boltPatternWide` DECIMAL(8,2) NULL,
  `extensionLength` DECIMAL(8,2) NULL,
  `overallLength` DECIMAL(8,2) NULL,
  `thickness` DECIMAL(8,2) NULL,
  `dropLength` DECIMAL(8,2) NULL,
  `mjClassCode` VARCHAR(25) NULL,
  `mjPlugClassCode` VARCHAR(25) NULL,
  `groove` BIT NULL,
  `uniqueFeature` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Elbow`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Elbow` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `boltPatternLong` DECIMAL(8,2) NULL,
  `boltPatternWide` DECIMAL(8,2) NULL,
  `extensionLength` DECIMAL(8,2) NULL,
  `overallLength` DECIMAL(8,2) NULL,
  `thickness` DECIMAL(8,2) NULL,
  `dropLength` DECIMAL(8,2) NULL,
  `angle` DECIMAL(6,2) NULL,
  `mjClassCode` VARCHAR(25) NULL,
  `mjPlugClassCode` VARCHAR(25) NULL,
  `plugDiameter` DECIMAL(8,2) NULL,
  `groove` BIT NULL,
  `uniqueFeature` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Float`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Float` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `boltPatternLong` DECIMAL(8,2) NULL,
  `boltPatternWide` DECIMAL(8,2) NULL,
  `thickness` DECIMAL(8,2) NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Hfl`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Hfl` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `hoseDiameter` DECIMAL(8,2) NULL,
  `correspondingShell` INT NULL,
  `couplingClass` VARCHAR(25) NULL,
  `material` VARCHAR(25) NULL,
  `plating` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  INDEX `correspondingShell_idx` (`correspondingShell` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `correspondingShell`
    FOREIGN KEY (`correspondingShell`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Nut`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Nut` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `hexNutSize` DECIMAL(8,2) NULL,
  `seatAngle` DECIMAL(8,2) NULL,
  `length` DECIMAL(8,2) NULL,
  `threadSize` DECIMAL(8,3) NULL,
  `threadPitch` DECIMAL(8,2) NULL,
  `diameter` DECIMAL(8,2) NULL,
  `blindHole` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Boss`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Boss` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `type` VARCHAR(25) NULL,
  `fkConnectionType` INT NULL,
  `outsideShape` VARCHAR(25) NULL,
  `baseType` VARCHAR(50) NULL,
  `heightOverTube` DECIMAL(8,2) NULL,
  `boltPatternLong` DECIMAL(8,2) NULL,
  `boltPatternWide` DECIMAL(8,2) NULL,
  `groove` BIT NULL,
  `baseDiameter` DECIMAL(8,2) NULL,
  `shoulderDiameter` DECIMAL(8,2) NULL,
  `uniqueFeature` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  INDEX `fkConnectionType_idx` (`fkConnectionType` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkConnectionType`
    FOREIGN KEY (`fkConnectionType`)
    REFERENCES `Caterpillar`.`ConnectionType` (`pkConnectionType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Adapter`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Adapter` (
  `fkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `adaptorAngle` DECIMAL(8,2) NULL,
  `overallLength` DECIMAL(8,2) NULL,
  `fkEndFormType1` INT NULL,
  `fkConnectionType1` INT NULL,
  `length1` DECIMAL(8,2) NULL,
  `threadSize1` DECIMAL(8,3) NULL,
  `threadPitch1` DECIMAL(8,2) NULL,
  `nominalSize1` DECIMAL(8,2) NULL,
  `fkEndFormType2` INT NULL,
  `fkConnectionType2` INT NULL,
  `length2` DECIMAL(8,2) NULL,
  `threadSize2` DECIMAL(8,3) NULL,
  `threadPitch2` DECIMAL(8,2) NULL,
  `nominalSize2` DECIMAL(8,2) NULL,
  `hexSize` DECIMAL(8,2) NULL,
  `uniqueFeature` BIT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  INDEX `fkEndFormType1_idx` (`fkEndFormType1` ASC),
  INDEX `fkEndFormType2_idx` (`fkEndFormType2` ASC),
  INDEX `fkConnectionType1_idx` (`fkConnectionType1` ASC),
  INDEX `fkConnectionType2_idx` (`fkConnectionType2` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkEndFormType1`
    FOREIGN KEY (`fkEndFormType1`)
    REFERENCES `Caterpillar`.`EndFormType` (`pkEndFormType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkEndFormType2`
    FOREIGN KEY (`fkEndFormType2`)
    REFERENCES `Caterpillar`.`EndFormType` (`pkEndFormType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkConnectionType1`
    FOREIGN KEY (`fkConnectionType1`)
    REFERENCES `Caterpillar`.`ConnectionType` (`pkConnectionType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkConnectionType2`
    FOREIGN KEY (`fkConnectionType2`)
    REFERENCES `Caterpillar`.`ConnectionType` (`pkConnectionType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Other`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Other` (
  `fkComponent` INT NOT NULL,
  `partName` VARCHAR(50) NOT NULL,
  UNIQUE INDEX `fkComponent_UNIQUE` (`fkComponent` ASC),
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
