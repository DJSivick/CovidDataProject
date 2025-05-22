Select *
From PortfolioProject..NashvilleHousing
------------------------------------------------------------------------------
-- Standardize Date Format

Select SaleDate, Convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

------------------------------------------------------------------------------
--Populate Property Address Data

Select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as filled
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

go

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


------------------------------------------------------------------------------
-- Break Address into Separate columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing

	-- Grab Address
	SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
	from PortfolioProject..NashvilleHousing

	-- Grab City
	SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
	from PortfolioProject..NashvilleHousing

	-- Update table
	Alter Table NashvilleHousing
	ADD PropertySplitAddress Nvarchar(255);

	Update NashvilleHousing 
	Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

	Alter Table NashvilleHousing
	ADD PropertySplitCity Nvarchar(255);

	Update NashvilleHousing 
	Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


	-- Grab Owner Info
	SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	From PortfolioProject..NashvilleHousing

	--Update Table
	ALTER TABLE NashvilleHousing
	Add OwnerSplitAddress Nvarchar(255);

	Update NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

	ALTER TABLE NashvilleHousing
	Add OwnerSplitCity Nvarchar(255);

	Update NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

	ALTER TABLE NashvilleHousing
	Add OwnerSplitState Nvarchar(255);

	Update NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

	Select *
	From PortfolioProject..NashvilleHousing

-- Change 0 and 1 to Yes and No in "Sold as Vacant" field
	Select Distinct(SoldAsVacant), Count(SoldAsVacant)
	from PortfolioProject..NashvilleHousing
	Group by SoldAsVacant
	order by 2
	
	Alter Table NashvilleHousing
	Alter Column SoldAsVacant Nvarchar(255);
	
	Select SoldAsVacant,
	Case When  SoldAsVacant = 1 then 'Yes'
		When  SoldAsVacant = 0 then 'No'
		ELSE SoldAsVacant
		END
	From PortfolioProject..NashvilleHousing;

	Update NashvilleHousing
	SET SoldAsVacant = 
	Case When  SoldAsVacant = 1 then 'Yes'
		When  SoldAsVacant = 0 then 'No'
		ELSE SoldAsVacant
		END
------------------------------------------------------------------------------
-- Remove Duplicates
go
with RowCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	Order by UniqueID) row_num

from PortfolioProject..NashvilleHousing
)

select * 
from RowCTE
where row_num > 1

--Delete *
--from RowCTE
--where row_num > 1

------------------------------------------------------------------------------
--remove unused columns

Select * 
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
