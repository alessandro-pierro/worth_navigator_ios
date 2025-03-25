#include "kml/serdes_geojson.hpp"

#include "coding/serdes_json.hpp"


namespace kml
{
namespace geojson
{


struct GeoJsonFeature
{
  DECLARE_VISITOR_AND_DEBUG_PRINT(GeoJsonFeature, visitor(m_type, "type"),
                                  visitor(m_properties, "properties"))

  bool operator==(GeoJsonFeature const & data) const
  {
    return m_type == data.m_type && m_properties == data.m_properties;
  }

  bool operator!=(GeoJsonFeature const & data) const { return !operator==(data); }

  std::string m_type = "Feature";
  std::map<std::string, std::string> m_properties;
};

struct GeoJsonData
{
  DECLARE_VISITOR_AND_DEBUG_PRINT(GeoJsonData, visitor(m_type, "type"),
                                  visitor(m_features, "features"))

  bool operator==(GeoJsonData const & data) const
  {
    return m_type == data.m_type;
  }

  bool operator!=(GeoJsonData const & data) const { return !operator==(data); }

  std::string m_type = "FeatureCollection";
  std::list<GeoJsonFeature> m_features;
};

void GeojsonWriter::Write(FileData const & fileData)
{
  GeoJsonData data;
  coding::SerializerJson<Writer> ser(m_writer);
  ser(data);
}

}  // namespace geojson
}  // namespace kml
