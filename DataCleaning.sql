SELECT *
FROM PortfolioProject..NashvilleHousing;

--Standardise Date Format

SELECT SalesDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(Date, SaleDate);

--Populate Property Address

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null;

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.ParcelID,b.ParcelID)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.ParcelID,b.ParcelID)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is null;

  -- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT *
From PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD 
OwnerSplitAddress Nvarchar(255), 
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

SELECT *
FROM PortfolioProject..NashvilleHousing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing;



UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                             WHEN SoldAsVacant = 'N' THEN 'No'
	                         ELSE SoldAsVacant
	                         END

--Remove Duplicates

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
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate