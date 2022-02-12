/*

Cleaning Data of Nashville Housing Datadset

*/

--Displaying all the dataset

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


-- Performing cleaning operations on dataset

--Standardize Date Format

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate); 


-- Populate Property Addres Data where the data is NULL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- Spliting Address into separate column (Address, City, State)


-- Spliting Property Address Column

SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , len(PropertyAddress)) AS State
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , len(PropertyAddress));


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing;


--- Spliting Owner Address Column


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3);



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1);


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


-- Change Y and N as yes and no in 'Sold in Vacant' Field

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

--Replacing Y and N as they are less in count

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


--Remove Duplicates


--Identifing duplicates

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY 
										UniqueID
										)row_num

FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT * 
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress;

--deleting duplicates

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY 
										UniqueID
										)row_num

FROM PortfolioProject.dbo.NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE row_num >1;



--Delecting Unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress, SaleDate
