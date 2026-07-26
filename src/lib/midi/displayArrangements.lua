-- Display arrangements of the per-control displays, see "Configure displays"
-- in the Launch Control XL 3 programmer's reference. Arrangement 4 (the
-- hardware default) shows the parameter name and the raw numeric 0-127 value;
-- arrangement 1 shows the parameter name and a text value the codec provides
-- (see makeParamValueDisplayEvent), for parameters whose host range is not
-- 0-127.
return {
  nameAndTextValue = 0x01,
  nameAndNumericValue = 0x04,
}
