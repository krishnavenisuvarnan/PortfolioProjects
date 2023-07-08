/*

Data Cleaning in SQL Queries
----------------------------

*/

Select *
from portfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------
--Populate Propety Address Data

select *
from PortfolioProject.dbo.NashvilleHousing

--Displaying the result when propertyAddress is missing

select a.parcelID,a.propertyaddress,b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID=b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Populating and Updating PropertyAddress

update a
set PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID=b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select *
from PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------
--Breaking Address into Individual Columns(Address, City, State)

--Using SUBSTRING to split from PropertyAddress
select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddres, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) as city
from PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress nvarchar(225);
 
UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(225);

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

--Using PARSENAME to split From OwnerAddress

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(225);
 
UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(225);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(225);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
  END
from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
       END

---------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates Using CTE :

--Finding the rows with Duplicated Data
WITH RowNumCTE AS (
select *,
      ROW_NUMBER() over(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
	               ORDER BY  
				           uniqueID
					    ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
where row_num > 1
order by PropertyAddress

--Deleting the found Duplicated Data

WITH RowNumCTE AS (
select *,
      ROW_NUMBER() over(
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
	               ORDER BY  
				           uniqueID
					    ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE
where row_num > 1
--order by PropertyAddress


---------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns :

select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

