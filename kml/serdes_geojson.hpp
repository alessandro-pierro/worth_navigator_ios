#pragma once

#include "kml/types.hpp"

#include "coding/writer.hpp"

#include "base/exception.hpp"

namespace kml
{
namespace geojson
{

class GeojsonWriter
{
public:
  DECLARE_EXCEPTION(WriteGeojsonException, RootException);

  explicit GeojsonWriter(Writer & writer)
    : m_writer(writer)
  {}

  void Write(FileData const & fileData);

private:
  Writer & m_writer;
};

}  // namespace geojson
}  // namespace kml
