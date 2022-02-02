-- DATA CLEANING W/ SQL QUERIES


SELECT *
FROM Portfolioproject..NashvilleHousing
--Standardize Date Format



ALTER TABLE NashvilleHousing
  ADD SaleDateConverted Date;


  UPDATE NashvilleHousing
   SET SaleDateConverted = CONVERT(Date, SaleDate)



SELECT SaleDateConverted,CONVERT(date, SaleDate)
FROM Portfolioproject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------

-- Populate Property Adress Data


SELECT *
 FROM Portfolioproject..NashvilleHousing
--WHERE PropertyAddress is null\
 ORDER BY ParcelID

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM Portfolioproject..NashvilleHousing a
 JOIN Portfolioproject..NashvilleHousing b
	  ON a.ParcelID = b.ParcelID
	  AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null

UPDATE a
   SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM Portfolioproject..NashvilleHousing a
  JOIN Portfolioproject..NashvilleHousing b
	   ON a.ParcelID = b.ParcelID
	   AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null


 ---------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) 
-- Using substring manipulation to slice address information into cleaner columns containing street address and city name

SELECT PropertyAddress
 FROM Portfolioproject..NashvilleHousing
--WHERE PropertyAddress is null\
 --ORDER BY ParcelID


SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Town
 FROM Portfolioproject..NashvilleHousing



ALTER TABLE NashvilleHousing
  ADD PropertyStAddress NVARCHAR(255);


  UPDATE NashvilleHousing
   SET PropertyStAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
  ADD PropertyCity NVARCHAR(255);


  UPDATE NashvilleHousing
   SET PropertyCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



SELECT *
FROM Portfolioproject..NashvilleHousing

------------------------------------------------

SELECT OwnerAddress
  FROM Portfolioproject..NashvilleHousing


SELECT
PARSENAME (REPLACE(OwnerAddress,',','.'), 3),
PARSENAME (REPLACE(OwnerAddress,',','.'), 2),
PARSENAME (REPLACE(OwnerAddress,',','.'), 1)
  FROM Portfolioproject..NashvilleHousing


ALTER TABLE NashvilleHousing
  ADD OwnerStAddress NVARCHAR(255);

 UPDATE NashvilleHousing
   SET OwnerStAddress = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
  ADD OwnerCity NVARCHAR(255);


  UPDATE NashvilleHousing
   SET OwnerCity = PARSENAME (REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
  ADD OwnerState NVARCHAR(255);


  UPDATE NashvilleHousing
   SET OwnerState = PARSENAME (REPLACE(OwnerAddress,',','.'), 1)

---------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant' field using CASE Statements

SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
FROM Portfolioproject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolioproject..NashvilleHousing



UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

---------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

--CREATE QUERY TO PARTITION DUPLICATE ROWS BASED ON COMMON COLUMN DATA :

SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelId, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID)
					row_num
	
FROM Portfolioproject..NashvilleHousing

--USE CTE AND 'DELETE' FUNCTION TO REMOVE ROWS W/DUPLICATE DATA (IDENTIFIED IN THE PARTITION COLUMN) :

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelId, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID)
					row_num
	
FROM Portfolioproject..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--RUN DELETE FUNCTION AS SELECT * QUERY, SHOULD RETURN EMPTY TABLE:

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelId, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID)
					row_num
	
FROM Portfolioproject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------------------
--Deleting Unused Columns

SELECT *
FROM Portfolioproject..NashvilleHousing

ALTER TABLE Portfolioproject..NashvilleHousing
DROP COLUMN SaleDate