SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `Caterpillar` DEFAULT CHARACTER SET utf8 ;
USE `Caterpillar` ;

-- -----------------------------------------------------
-- Table `Caterpillar`.`ComponentType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`ComponentType` (
  `pkComponentType` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`pkComponentType`),
  UNIQUE INDEX `pkComponentType_UNIQUE` (`pkComponentType` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`ConnectionType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`ConnectionType` (
  `pkConnectionType` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  UNIQUE INDEX `pkConnectionType_UNIQUE` (`pkConnectionType` ASC),
  PRIMARY KEY (`pkConnectionType`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeEndForm`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeEndForm` (
  `pkTubeEndForm` INT NOT NULL,
  `forming` BIT NOT NULL,
  UNIQUE INDEX `pkTubeEndForm_UNIQUE` (`pkTubeEndForm` ASC),
  PRIMARY KEY (`pkTubeEndForm`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component` (
  `pkComponent` INT NOT NULL,
  `fkComponentType` INT NOT NULL,
  `weight` DECIMAL(8,3) NULL,
  `overallLength` DECIMAL(8,3) NULL,
  `hexSize` DECIMAL(8,3) NULL,
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
  `pkEndFormType` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`pkEndFormType`),
  UNIQUE INDEX `pkEndFormType_UNIQUE` (`pkEndFormType` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeAssembly`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssembly` (
  `pkTubeAssembly` INT NOT NULL,
  `materialID` VARCHAR(20) NULL,
  `diameter` DECIMAL(8,2) NULL,
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
-- Table `Caterpillar`.`Component_Connection`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Connection` (
  `fkComponent` INT NOT NULL,
  `fkEndFormType` INT NULL,
  `fkConnectionType` INT NULL,
  `length` DECIMAL(8,2) NULL,
  `threadSize` DECIMAL(8,2) NULL,
  `threadPitch` DECIMAL(8,2) NULL,
  `nominalSize` DECIMAL(8,2) NULL,
  INDEX `fkEndFormTypeConnection_idx` (`fkEndFormType` ASC),
  INDEX `fkConnectionConnection_idx` (`fkConnectionType` ASC),
  INDEX `fkComponentConnection_idx` (`fkComponent` ASC),
  CONSTRAINT `fkComponentConnection`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkEndFormTypeConnection`
    FOREIGN KEY (`fkEndFormType`)
    REFERENCES `Caterpillar`.`EndFormType` (`pkEndFormType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkConnectionConnection`
    FOREIGN KEY (`fkConnectionType`)
    REFERENCES `Caterpillar`.`ConnectionType` (`pkConnectionType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `Caterpillar` ;

-- -----------------------------------------------------
-- Placeholder table for view `Caterpillar`.`TubeAssemblyWeightView`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssemblyWeightView` (`fkTubeAssembly` INT, `totalWeight` INT);

-- -----------------------------------------------------
-- View `Caterpillar`.`TubeAssemblyWeightView`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Caterpillar`.`TubeAssemblyWeightView`;
USE `Caterpillar`;
CREATE  OR REPLACE VIEW `TubeAssemblyWeightView` AS
	Select fkTubeAssembly, SUM(C.weight * TAC.quantity) AS totalWeight
	From Component AS C
		INNER JOIN TubeAssembly_Component AS TAC ON C.pkComponent = TAC.fkComponent
	GROUP BY TAC.fkTubeAssembly;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
